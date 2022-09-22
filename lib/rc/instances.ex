defmodule RC.Instances do
  @moduledoc """
  The Instances context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias RC.Accounts.Account
  alias RC.Instances
  alias RC.Instances.Faction
  alias RC.Instances.InstanceState
  alias RC.Instances.InstanceStateMachine
  alias RC.Instances.RegistrationStateMachine
  alias RC.Instances.Victory
  alias RC.InstanceSnapshots
  alias RC.Registrations
  alias RC.Repo

  require Logger

  @doc """
  Returns `true` if the instance is owned by the account with id `account_id`.
  """
  def own_instance?(account_id, instance_id) do
    Repo.exists?(
      from(i in Instances.Instance,
        join: a in Account,
        on: i.account_id == a.id,
        where: i.id == ^instance_id and a.id == ^account_id
      )
    )
  end

  @doc """
  Updates the Instances state to `open`.
  """
  def publish_instance(instance, account_id) do
    with {:ok, updated_instance} <- update_instance(instance, %{registration_status: :open}),
         {:ok, updated_instance} <-
           updated_instance
           |> Map.put(:account_id, account_id)
           |> Machinery.transition_to(InstanceStateMachine, "open") do
      {:ok, updated_instance}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Updates the Instances state to `paused`.

  It does not pause the Instance supervisor.
  """
  def pause_instance(instance, account_id) do
    instance
    |> Map.put(:account_id, account_id)
    |> Machinery.transition_to(InstanceStateMachine, "paused")
  end

  @doc """
  Updates the Instances state to `running` when the state is `paused`.

  It does not start again the Instance supervisor.
  """
  def resume_instance(instance, account_id) do
    instance
    |> Map.put(:account_id, account_id)
    |> Machinery.transition_to(InstanceStateMachine, "running")
  end

  @doc """
  Updates the Instances state to `running` when the state is `not_running`.

  It does not start again the Instance supervisor.
  """
  def restart_instance(instance, account_id) do
    instance
    |> Map.put(:account_id, account_id)
    |> Machinery.transition_to(InstanceStateMachine, "running")
  end

  @doc """
  Updates the `registration_status` if need be and frees all profiles .

  It does not kill the instance supervisor.
  """
  def close_instance(instance) do
    with {:ok, instance} <- close_instance_registration(instance, "finish") do
      {:ok, instance}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Updates instance's state to `ended`.
  """
  def finish_instance(instance, account_id) do
    instance
    |> Map.put(:account_id, account_id)
    |> Machinery.transition_to(InstanceStateMachine, "ended")
  end

  @doc """
  Updates the Instances state to `running`, updates all the registrations states to `playing` and the `registration_status` if needed.

  It does not start the instance supervisor.
  """
  def start_instance(instance, account_id) do
    with {:ok, instance} <- close_instance_registration(instance, "start"),
         {:ok, instance} <-
           Machinery.transition_to(instance |> Map.put(:account_id, account_id), InstanceStateMachine, "running") do
      registrations = Registrations.filter_by_state(instance.id, "joined")

      {registrations_errors_count, updated_registrations} =
        Enum.reduce(registrations, {0, []}, fn registration, {acc, reg_acc} ->
          case Machinery.transition_to(registration, RegistrationStateMachine, "playing") do
            {:ok, updated_registration} -> {acc, reg_acc ++ [updated_registration]}
            {:error, _reason} -> {acc + 1, reg_acc}
          end
        end)

      {:ok,
       %{instance: instance, registrations: updated_registrations, registrations_errors: registrations_errors_count}}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp close_instance_registration(%{registration_type: :pre_registration} = instance, "start"),
    do: update_instance(instance, %{registration_status: :closed})

  defp close_instance_registration(%{registration_type: :late_registration} = instance, "finish"),
    do: update_instance(instance, %{registration_status: :closed})

  defp close_instance_registration(instance, _action) do
    {:ok, instance}
  end

  @doc """
  Transition an instance to the `maintenance` state. If the server is running or paused a snapshot is made.
  """
  def maintenance_instance(instance, account_id) do
    maintenance_done =
      case instance.state do
        "running" ->
          with {:ok, :stopped, _} <- Instance.Manager.call(instance.id, :stop),
               {:ok, _instance_snapshot} <- Instance.Manager.call(instance.id, :make_snapshot),
               {:ok, _instance} <- Instance.Manager.destroy(instance.id) do
            true
          else
            {:error, reason} ->
              Logger.error(inspect(reason))
              false
          end

        "paused" ->
          with {:ok, _instance_snapshot} <- Instance.Manager.call(instance.id, :make_snapshot),
               {:ok, _instance} <- Instance.Manager.destroy(instance.id) do
            true
          else
            {:error, reason} ->
              Logger.error(inspect(reason))
              false
          end

        state when state in ["open", "created", "not_running", "ended"] ->
          true
      end

    if maintenance_done do
      instance
      |> Map.put(:account_id, account_id)
      |> Machinery.transition_to(InstanceStateMachine, "maintenance")
    else
      {:error, :maintenance_failed}
    end
  end

  @doc """
  Transition the instance to the state it was before the maintenance. Load the last snapshot if the server was previously running or paused.
  """
  def restore_instance(instance, account_id) do
    previous_state = get_previous_instance_state(instance.id)

    restored =
      case previous_state do
        "running" ->
          # get most recent snapshot
          with instance_snapshot when not is_nil(instance_snapshot) <- InstanceSnapshots.last(instance.id),
               {:ok, snapshot} <- Util.Storage.load(instance_snapshot.name),
               {:ok, :instantiated} <- Instance.Manager.create_from_snapshot(instance.id, snapshot),
               Process.sleep(5_000),
               {:ok, :started, _} <- Instance.Manager.call(instance.id, :start) do
            true
          else
            nil ->
              Logger.error("Missing snapshot for instance #{instance.id}")
              false

            {:error, reason} ->
              Logger.error(inspect(reason))
              false
          end

        "paused" ->
          with instance_snapshot when not is_nil(instance_snapshot) <- InstanceSnapshots.last(instance.id),
               {:ok, snapshot} <- Util.Storage.load(instance_snapshot.name),
               {:ok, :instantiated} <- Instance.Manager.create_from_snapshot(instance.id, snapshot) do
            true
          else
            nil ->
              Logger.error("Missing snapshot for instance #{instance.id}")
              false

            {:error, reason} ->
              Logger.error(inspect(reason))
              false
          end

        state when state in ["open", "created", "not_running", "ended"] ->
          true
      end

    if restored do
      instance
      |> Map.put(:account_id, account_id)
      |> Machinery.transition_to(InstanceStateMachine, previous_state)
    else
      {:error, :restoration_failed}
    end
  end

  @doc """
  Only for use in the admin panel.
  Filtered by params.
  """
  def list_instances_admin(params) do
    {state_filter, filtrex_params} =
      Map.drop(params, ["page"])
      |> remove_json_filters()
      |> Map.pop("state")

    config = Instances.Instance.filter_options()

    case Filtrex.parse_params(config, filtrex_params) do
      {:ok, filter} ->
        instances =
          Instances.Instance
          |> order_by(desc: :id)
          |> put_instance_json_filters(params)
          |> put_state_filter(state_filter)
          |> Filtrex.query(filter)
          |> Repo.paginate(params)

        entries = Enum.map(instances.entries, &put_instance_supervisor_status(&1))
        instances = Map.put(instances, :entries, entries)
        {:ok, instances}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Returns
    - Instances,
    - with preloaded factions,
    - and count Registrations.

  Filtered by params.
  """
  def list_instances(params, :count_registrations, aid \\ nil) do
    {state_filter, filtrex_params} =
      Map.drop(params, ["page"])
      |> remove_json_filters()
      |> Map.pop("state")

    config = Instances.Instance.filter_options()

    case Filtrex.parse_params(config, filtrex_params) do
      {:ok, filter} ->
        preload_query =
          from(faction in Faction,
            left_join: registrations in assoc(faction, :registrations),
            group_by: faction.id,
            order_by: faction.id,
            select_merge: %{registrations_count: count(registrations.id)}
          )

        query =
          if aid != nil do
            from(i in Instances.Instance,
              left_join: ig in RC.Groups.InstanceGroup,
              on: ig.instance_id == i.id,
              left_join: ag in RC.Groups.AccountGroup,
              on: ig.group_id == ag.group_id,
              where: ag.account_id == ^aid or (is_nil(ig.group_id) and i.public == true and i.state != "created"),
              order_by: [desc: i.id],
              preload: [factions: ^preload_query]
            )
          else
            from(i in Instances.Instance,
              order_by: [desc: i.id],
              preload: [factions: ^preload_query]
            )
          end

        instances =
          query
          |> put_instance_json_filters(params)
          |> put_state_filter(state_filter)
          |> Filtrex.query(filter)
          |> Repo.paginate(params)

        entries = Enum.map(instances.entries, &put_instance_supervisor_status(&1))
        instances = Map.put(instances, :entries, entries)

        {:ok, instances}

      {:error, error} ->
        {:error, error}
    end
  end

  def list_instances_with_state(state) when is_binary(state),
    do: from(i in Instances.Instance, where: i.state == ^state) |> Repo.all()

  def list_instances_with_state(states) when is_list(states),
    do: from(i in Instances.Instance, where: i.state in ^states) |> Repo.all()

  defp put_state_filter(query, nil), do: query

  defp put_state_filter(query, state_filter) do
    states = String.split(state_filter, ",")
    query |> where([i], i.state in ^states)
  end

  @doc """
  Gets a single instance.

  Raises `Ecto.NoResultsError` if the Instance does not exist.

  ## Examples

      iex> get_instance(123)
      %Instances.Instance{}

      iex> nil

  """
  def get_instance(id) do
    preload_query =
      from(faction in Faction,
        left_join: registrations in assoc(faction, :registrations),
        group_by: faction.id,
        select_merge: %{registrations_count: count(registrations.id)}
      )

    query =
      from(i in Instances.Instance, where: i.id == ^id)
      |> preload(factions: ^preload_query)
      |> preload(:groups)

    case Repo.one(query) do
      nil -> nil
      instance -> put_instance_supervisor_status(instance)
    end
  end

  @doc """
  Gets a single instance with registration.
  It is used to feed a starting game.
  """
  def get_instance_with_registration(id) do
    query =
      from(instance in Instances.Instance,
        join: faction in assoc(instance, :factions),
        left_join: registration in assoc(faction, :registrations),
        left_join: profile in assoc(registration, :profile),
        left_join: state in assoc(instance, :states),
        preload: [factions: {faction, registrations: {registration, profile: profile}}, states: state],
        where: instance.id == ^id
      )

    case Repo.one(query) do
      nil -> nil
      instance -> put_instance_supervisor_status(instance)
    end
  end

  @doc """
  Gets all states from a single instance.
  """
  def get_instance_states(id) do
    query =
      from(s in Instances.InstanceState,
        where: s.instance_id == ^id,
        order_by: [desc: s.inserted_at]
      )
      |> preload(:account)

    Repo.all(query)
  end

  @doc """
  Checks if an instance influences rankings.

  For instance it must be game_mode_type = ranked AND speed = fast
  """
  def instance_is_ranked(instance_id) do
    instance =
      from(i in Instances.Instance,
        where: i.id == ^instance_id and fragment("game_data @> ?", ^%{game_mode_type: "ranked", speed: "fast"})
      )
      |> Repo.one()

    case instance do
      nil -> false
      _ -> true
    end
  end

  @doc """
  Creates a instance.

  ## Examples

      iex> create_instance(%{field: value})
      {:ok, %Instances.Instance{}}

      iex> create_instance(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_instance(attrs, %{game_data: game_data, game_metadata: game_metadata} = _scenario, account_id) do
    factions =
      if not is_nil(attrs["factions"]),
        do:
          Enum.map(attrs["factions"], fn faction ->
            %Faction{}
            |> Faction.changeset(%{
              faction_ref: faction["key"],
              capacity: faction["capacity"]
            })
          end),
        else: []

    game_data =
      if Map.has_key?(attrs, "game_mode_type"),
        do: Map.put(game_data, "game_mode_type", attrs["game_mode_type"]),
        else: game_data

    game_data =
      if Map.has_key?(attrs, "seed"),
        do: Map.replace!(game_data, "seed", attrs["seed"]),
        else: game_data

    instance_attrs =
      attrs
      |> Map.put("state", "created")
      |> Map.put("game_data", game_data)
      |> Map.put("game_metadata", game_metadata)
      |> Map.put("account_id", account_id)
      |> Map.put("registration_status", "closed")

    instance =
      %Instances.Instance{}
      |> Instances.Instance.changeset(instance_attrs)

    instance_with_factions = Ecto.Changeset.put_assoc(instance, :factions, factions)

    trx =
      Multi.new()
      |> Multi.insert(:instance, instance_with_factions)
      |> Multi.insert(:instance_state, fn %{instance: instance} ->
        instance_state_attrs = %{
          state: "created",
          instance_id: instance.id,
          account_id: account_id
        }

        InstanceState.changeset(%InstanceState{}, instance_state_attrs)
      end)

    Repo.transaction(trx)
  end

  @doc """
  Fixes instance state vs instance supervisor state mismatches.
  Always called at startup, otherwise only call it manually.

  When an instance is being moved from one node to another, we don't want
  its state to be set to `not_running` here by accident.
  """
  def update_instances_state_if_needed(fix \\ false) do
    to_fix =
      from(i in Instances.Instance)
      |> preload(:states)
      |> Repo.all()
      |> Enum.map(fn instance ->
        instance
        |> put_instance_supervisor_status()
      end)
      |> Enum.filter(fn %{supervisor_status: supervisor_status, state: state} ->
        cond do
          state == "running" and supervisor_status != :running ->
            true

          state == "paused" and supervisor_status != :instantiated ->
            true

          state == "not_running" and supervisor_status != :not_instantiated ->
            true

          true ->
            false
        end
      end)

    if fix do
      to_fix
      |> Enum.map(&update_instance_state_if_needed/1)
    else
      to_fix
    end
  end

  def put_instance_supervisor_status(instance) do
    supervisor_status = Instance.Manager.get_status(instance.id)

    node =
      case Instance.Manager.get_pid(instance.id, 1) do
        {:ok, pid} -> inspect(Kernel.node(pid))
        _ -> ""
      end

    instance
    |> Map.put(:supervisor_status, supervisor_status)
    |> Map.put(:node, node)
  end

  # TODO put required json filters
  defp put_instance_json_filters(query, filters) when is_map(filters) do
    Enum.reduce(filters, query, fn {key, val}, query_acc ->
      case key do
        "speed" -> where(query_acc, fragment("game_metadata @> ?", ^%{speed: val}))
        _ -> query_acc
      end
    end)
  end

  # Remove json filters that are conflicting with Filtrex filters
  # TODO: remove keys that are added in `put_instance_json_filter/2` above.
  defp remove_json_filters(filters) do
    filters
    |> Map.drop(["speed"])
  end

  # Update the state in DB to "not_running" if the instance's supervisor was unexpectedly stopped
  defp update_instance_state_if_needed(%{supervisor_status: supervisor_status, state: state} = instance) do
    new_state =
      cond do
        state == "running" and supervisor_status == :not_instantiated ->
          "not_running"

        state == "running" and supervisor_status == :instantiated ->
          "paused"

        state == "paused" and supervisor_status == :running ->
          "running"

        state == "paused" and supervisor_status == :not_instantiated ->
          "not_running"

        state == "not_running" and supervisor_status == :running ->
          "running"

        state == "not_running" and supervisor_status == :instantiated ->
          "paused"

        true ->
          Logger.error("Cannot fix #{state}/#{supervisor_status}")
          state
      end

    Logger.info("instance #{instance.id} state set to #{new_state}, was #{state}")
    set_instance_state(instance, new_state)
  end

  defp update_instance_state_if_needed(instance), do: instance

  defp set_instance_state(instance, state) do
    case create_instance_state(%{instance_id: instance.id, state: state}, instance.account_id) do
      {:ok, %{instance: instance, instance_state: instance_state}} ->
        instance
        |> Map.put(:states, [instance_state | instance.states])

      {:error, failed_operation, _failed_value, _changes_so_far} ->
        Logger.error(inspect(failed_operation))
        instance
    end
  end

  def record_victory(rankings, victory_type) do
    winning_faction = List.first(rankings)
    winning_faction = get_faction(winning_faction.id)

    victory = Victory.changeset(%Victory{}, %{instance_id: winning_faction.instance_id, victory_type: victory_type})

    rankings
    |> Enum.with_index()
    |> Enum.reduce(Multi.new(), fn {rankings, index}, trx ->
      faction = get_faction(rankings.id)
      faction_changeset = Faction.changeset(faction, %{final_rank: index + 1})
      Multi.update(trx, "update_faction_#{rankings.key}", faction_changeset)
    end)
    |> Multi.insert("insert_victory", victory)
    |> Repo.transaction()
  end

  @doc """
  Updates a instance.

  ## Examples

      iex> update_instance(instance, %{field: new_value})
      {:ok, %Instances.Instance{}}

      iex> update_instance(instance, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_instance(%Instances.Instance{} = instance, attrs) do
    instance
    |> Instances.Instance.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Instances.Instance.

  ## Examples

      iex> delete_instance(instance)
      {:ok, %Instances.Instance{}}

      iex> delete_instance(instance)
      {:error, %Ecto.Changeset{}}

  """
  def delete_instance(%Instances.Instance{} = instance) do
    instance
    |> Repo.delete()
  end

  @doc """
  Creates an InstanceState.
  """
  def create_instance_state(%{instance_id: instance_id, state: state} = attrs) do
    instance_state =
      %InstanceState{}
      |> InstanceState.changeset(attrs)

    instance =
      Repo.get_by(Instances.Instance, id: instance_id)
      |> Instances.Instance.changeset(%{state: state})

    Multi.new()
    |> Multi.insert(:instance_state, instance_state)
    |> Multi.update(:instance, instance)
    |> Repo.transaction()
  end

  @doc """
  Creates an InstanceState associated to an account id.
  """
  def create_instance_state(%{instance_id: instance_id, state: state} = attrs, account_id) do
    instance_state =
      %InstanceState{}
      |> Map.put(:account_id, account_id)
      |> InstanceState.changeset(attrs)

    instance =
      Repo.get_by(Instances.Instance, id: instance_id)
      |> Instances.Instance.changeset(%{state: state})

    Multi.new()
    |> Multi.insert(:instance_state, instance_state)
    |> Multi.update(:instance, instance)
    |> Repo.transaction()
  end

  def get_previous_instance_state(instance_id) do
    # Returns the previous state of an instance. Returns `:error` if there is no previous state.
    states =
      from(instance_state in InstanceState,
        where: instance_state.instance_id == ^instance_id,
        order_by: [desc: instance_state.inserted_at],
        limit: 2
      )
      |> Repo.all()

    case states do
      [_current_state | [previous_state]] -> previous_state.state
      _ -> :error
    end
  end

  @doc """
  Gets a single faction.

  Returns nil if the Faction does not exist.

  ## Examples

      iex> get_faction(123)
      %Faction{}

      iex> get_faction(456)
      nil

  """
  def get_faction(id), do: Repo.get(Faction, id)

  @doc """
  Updates the corresponding `registration` state to `resigned`, and free the profile.
  Return {:error, reason} if there was en error.
  """
  def resign_player(faction_id, profile_id) do
    resign_or_kill_player(faction_id, profile_id, "resigned")
  end

  @doc """
  Updates the corresponding `registration` state to `dead`, and free the profile.
  Return {:error, reason} if there was en error.
  """
  def kill_player(faction_id, profile_id) do
    resign_or_kill_player(faction_id, profile_id, "dead")
  end

  defp resign_or_kill_player(faction_id, profile_id, next_state) do
    registration = Registrations.get(%{faction_id: faction_id, profile_id: profile_id})

    Registrations.transition_to(registration, next_state)
  end
end
