defmodule RC.Registrations do
  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias RC.Accounts.Profile
  alias RC.Instances.Faction
  alias RC.Instances.Registration
  alias RC.Instances.RegistrationState
  alias RC.Instances.RegistrationStateMachine
  alias RC.Repo

  @doc """
  Creates a `registration` with state `joined` for a `profile` into a `faction`.

  Returns {:error, failed_operation, failed_value, changes_so_far} if any errors.
  """
  def register_profile(faction, profile, registration_initial_state \\ "joined") do
    registration =
      Registration.changeset(%Registration{}, %{
        token: Registration.generate_token(),
        faction_id: faction.id,
        profile_id: profile.id,
        state: registration_initial_state
      })

    trx =
      Multi.new()
      |> Multi.insert(:registration, registration)
      |> Multi.insert(:registration_state, fn %{registration: registration} ->
        registration_state_attrs = %{
          state: registration_initial_state,
          registration_id: registration.id
        }

        RegistrationState.changeset(%RegistrationState{}, registration_state_attrs)
      end)

    Repo.transaction(trx)
  end

  @doc """
  Updates the `registration` state to `state`, if possible.
  Return {:error, reason} if the transition failed.
  """
  def transition_to(%Registration{} = registration, state) do
    Machinery.transition_to(registration, RegistrationStateMachine, state)
  end

  @doc """
  Returns the `%Registration{}` of a profile with id `profile_id` registered in the faction with id `faction_id`.
  """
  def get(%{faction_id: faction_id, profile_id: profile_id}) do
    from(r in Registration,
      left_join: state in assoc(r, :states),
      group_by: [r.id, state.inserted_at, state.state],
      order_by: [desc: state.inserted_at],
      limit: 1,
      where: r.faction_id == ^faction_id and r.profile_id == ^profile_id,
      select_merge: %{state: state.state}
    )
    |> Repo.one()
  end

  @doc """
  Returns true if the account is already registered with a profile into the instance
  """
  def registered?(%{instance_id: instance_id, account_id: account_id}) do
    from(r in Registration,
      join: p in Profile,
      on: p.id == r.profile_id,
      join: f in Faction,
      on: f.id == r.faction_id,
      where: p.account_id == ^account_id and f.instance_id == ^instance_id
    )
    |> Repo.exists?()
  end

  @doc """
  All registrations of an instance
  """
  def list(instance_id) do
    from(registration in Registration,
      join: faction in Faction,
      on: faction.id == registration.faction_id,
      where: faction.instance_id == ^instance_id,
      order_by: [asc: :inserted_at]
    )
    |> preload([:states, :profile, :faction])
    |> Repo.all()
    |> Enum.map(&put_last_state(&1))
  end

  @doc """
  Registrations by faction of an instance
  """
  def list_by_faction(instance_id, faction_id) do
    from(registration in Registration,
      join: faction in assoc(registration, :faction),
      join: profile in assoc(registration, :profile),
      where: faction.instance_id == ^instance_id and faction.id == ^faction_id
    )
    |> preload([:profile])
    |> Repo.all()
  end

  def filter_by_state(instance_id, registration_state) do
    from(registration in Registration,
      join: faction in Faction,
      on: faction.id == registration.faction_id,
      where: faction.instance_id == ^instance_id,
      order_by: [asc: :inserted_at]
    )
    |> preload(:states)
    |> Repo.all()
    |> Enum.map(&put_last_state(&1))
    |> Enum.filter(&(&1.state == registration_state))
  end

  @doc """
  Updates a Registration.
  """
  def update(%Registration{} = registration, attrs) do
    registration
    |> Registration.changeset(attrs)
    |> Repo.update()
  end

  def valid?(instance_id, token) do
    query =
      from(registration in Registration,
        left_join: faction in assoc(registration, :faction),
        left_join: instance in assoc(faction, :instance),
        preload: [faction: {faction, instance: instance}],
        left_join: state in assoc(registration, :states),
        group_by: [registration.id, state.state, faction.id, instance.id, state.inserted_at],
        order_by: [desc: state.inserted_at],
        limit: 1,
        where: instance.id == ^instance_id and registration.token == ^token,
        select_merge: %{state: state.state}
      )

    case Repo.one(query) do
      nil -> {:error, :registration_not_valid}
      registration -> {:ok, registration}
    end
  end

  @doc """
  Returns the Registrations count in a Faction.
  """
  def count_by_faction(faction_id) do
    Repo.aggregate(from(r in Registration, where: r.faction_id == ^faction_id), :count, :id)
  end

  defp put_last_state(%{states: states} = schema_struct) do
    last_state = Enum.max_by(states, & &1.inserted_at, DateTime)
    schema_struct |> Map.put(:state, last_state.state)
  end
end
