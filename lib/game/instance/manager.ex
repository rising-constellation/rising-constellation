defmodule Instance.Manager do
  @moduledoc """
  GenServer used to manage an instance:
  - creating its supervision tree
  - starting the instance
  - etc
  """

  use GenServer
  require Logger
  alias Portal.Controllers.PortalChannel

  # GenServers that are not TickServers, we don't want to send them :start/:stop/:get_full_state
  @no_tick [Spatial.Supervisor, Instance.Manager]

  def start_link(opts) do
    instance_id = Keyword.get(opts, :id)

    case GenServer.start_link(__MODULE__, opts, name: {:via, Horde.Registry, {Game.Registry, {instance_id, :manager}}}) do
      {:ok, pid} ->
        Logger.warn("starting instance #{instance_id}: #{inspect(pid)}")
        {:ok, pid}

      {:error, {:already_started, _pid}} ->
        :ignore
    end
  end

  ## Client API

  @doc """
  Get the pid of an instance manager
  """
  def get_pid(_instance_id, _attempts \\ 5)

  def get_pid(instance_id, attempts) when is_binary(instance_id),
    do: String.to_integer(instance_id) |> get_pid(attempts)

  def get_pid(instance_id, attempts), do: Game.get_pid({instance_id, :manager}, attempts)

  @doc """
  Send a message to an instance manager

  Big timeout by default because starting/stopping big instances (>10k systems) can take a while
  """
  def call(instance_id, action, timeout \\ 30_000) do
    GenServer.call(Game.via_tuple({instance_id, :manager}), action, timeout)
  end

  @doc """
  Return the instance status
  Returns `:not_instantiated` | `:instantiated` | `:running`.
  """
  def get_status(instance_id) do
    with true <- created?(instance_id),
         {:ok, %{is_running: true}} <- Game.call_no_log(instance_id, :time, :master, :get_state) do
      :running
    else
      false -> :not_instantiated
      :process_not_found -> :not_instantiated
      {:ok, %{is_running: false}} -> :instantiated
    end
  end

  @doc """
  Create an instance from an instance map

  Returns {:ok, :instantiated} | {:error, reason}
  """
  def create_from_model(instance, tutorial_id, channel \\ nil) do
    with false <- created?(instance.id),
         {:ok, supervisor_pid} <- create(instance.id, channel),
         {:ok, _pid} <- get_pid(instance.id, 10),
         {:ok, :instantiated} <-
           GenServer.call(
             Game.via_tuple({instance.id, :manager}),
             {:init_from_model, supervisor_pid, instance, tutorial_id, channel},
             :infinity
           ) do
      {:ok, :instantiated}
    else
      true ->
        {:error, :already_created}

      err ->
        err
    end
  end

  @doc """
  Creates an instance from a snapshot file

  Returns {:ok, :instantiated} | {:error, reason}
  """
  def create_from_snapshot(instance_id, snapshot) when is_binary(instance_id),
    do: String.to_integer(instance_id) |> create_from_snapshot(snapshot)

  def create_from_snapshot(instance_id, snapshot) do
    case create(instance_id) do
      {:ok, supervisor_pid} -> init_from_snapshot(supervisor_pid, instance_id, snapshot)
      err -> err
    end
  end

  @doc """
  Tests if the instance has been created (is instantiated)

  Returns `true` | `false`.
  """
  def created?(instance_id) do
    case Instance.Supervisor.get_pid(instance_id) do
      {:ok, _} -> true
      _ -> false
    end
  end

  @doc """
  Kill all childrens' tick_server given an `id` instance.

  Returns {:ok, :killed} | {:error, :instance_not_found}
  """
  def destroy(instance_id) do
    case created?(instance_id) do
      true ->
        # kill all children objects
        {:ok, supervisor_pid} = Instance.Supervisor.get_pid(instance_id)
        Horde.DynamicSupervisor.terminate_child(Game.Supervisor, supervisor_pid)

        # clear cached data
        Data.Data.clear(instance_id)
        Data.GenServerState.wait_and_clear(instance_id)

        {:ok, :killed}

      false ->
        {:error, :instance_not_found}
    end
  end

  @doc """
  Kill a child process.

  Returns :ok | {:error, :not_found}
  """
  def kill_child(instance_id, name_tuple) do
    {:ok, supervisor_pid} = Instance.Supervisor.get_pid(instance_id)
    {:ok, pid} = Game.get_pid(name_tuple)
    GenServer.call(pid, :prepare_kill)
    DynamicSupervisor.terminate_child(supervisor_pid, pid)
  end

  def fix_agents(instance_id) do
    case Instance.Supervisor.get_pid(instance_id) do
      {:ok, supervisor_pid} ->
        {_, galaxy_pid, _, _} =
          DynamicSupervisor.which_children(supervisor_pid)
          |> Enum.find(fn {_, _, _, [module | _]} -> module == Instance.Galaxy.Agent end)

        {:ok, galaxy_state} = GenServer.call(galaxy_pid, :get_state)

        DynamicSupervisor.which_children(supervisor_pid)
        |> Enum.filter(fn {_, _, _, [module | _]} -> module == Instance.Character.Agent end)
        |> Enum.reduce(0, fn {_, child_pid, _, _}, acc ->
          case GenServer.call(child_pid, {:fix, galaxy_state.stellar_systems}) do
            :fixed -> acc + 1
            :no_fix_needed -> acc
          end
        end)

      _ ->
        :error
    end
  end

  # Callbacks

  @impl true
  def init(opts) do
    Process.flag(:trap_exit, true)
    instance_id = Keyword.get(opts, :id)
    state = %{instance_id: instance_id}
    {:ok, state}
  end

  @impl true
  def terminate(_reason, _state) do
    Process.sleep(10_000)
  end

  @impl true
  def handle_call({:init_from_model, supervisor_pid, instance, tutorial_id}, _from, state) do
    result = init_from_model(supervisor_pid, instance, tutorial_id)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:init_from_model, supervisor_pid, instance, tutorial_id, channel}, _from, state) do
    result = init_from_model(supervisor_pid, instance, tutorial_id, channel)
    {:reply, result, state}
  end

  # Start all children's tick_server
  # Returns {:ok, :started, process_started_count} | {:error, :instance_not_found}
  @impl true
  def handle_call(:start, _from, %{instance_id: instance_id} = state) do
    result =
      case Instance.Supervisor.get_pid(instance_id) do
        {:ok, supervisor_pid} -> start(instance_id, supervisor_pid)
        {:error, :process_not_found} -> {:error, :instance_not_found}
      end

    {:reply, result, state}
  end

  # Stop all children's tick_server
  # Returns {:ok, :stopped, process_stopped_count} | {:error, :instance_not_found}
  def handle_call(:stop, _from, %{instance_id: instance_id} = state) do
    result =
      case Instance.Supervisor.get_pid(instance_id) do
        {:ok, supervisor_pid} -> stop(supervisor_pid)
        {:error, :process_not_found} -> {:error, :instance_not_found}
      end

    {:reply, result, state}
  end

  # Add a player to the instance
  # Returns {:ok} | {:error, :instance_not_found}
  def handle_call({:add_player, faction, profile, registration_id}, _from, %{instance_id: instance_id} = state) do
    result =
      case Instance.Supervisor.get_pid(instance_id) do
        {:ok, supervisor_pid} -> add_player(supervisor_pid, instance_id, faction, profile, registration_id)
        {:error, :process_not_found} -> {:error, :instance_not_found}
      end

    {:reply, result, state}
  end

  # Creates a snapshot and writes it somewhere
  def handle_call(:make_snapshot, _from, %{instance_id: instance_id} = state) do
    result = create_snapshot(instance_id)

    {:reply, result, state}
  end

  ## Private API - implementations

  defp init_from_model(supervisor_pid, instance, tutorial_id, progress_channel \\ nil) do
    instance_id = instance.id
    game_data = instance.game_data
    user_broadcast(progress_channel, :step_4, instance_id)

    metadata = [
      speed: String.to_existing_atom(game_data["speed"]),
      mode: String.to_existing_atom(game_data["mode"]),
      seed: game_data["seed"] |> List.to_tuple()
    ]

    # PREPARATION STEP

    # cache instance storage metadata
    Data.Data.insert(instance_id, metadata)

    speed = Data.Querier.one(Data.Game.Speed, instance_id, metadata[:speed])
    calendar = Data.Querier.one(Data.Game.Calendar, instance_id, :tetrarch)

    # set starting date, An_Integer / 1 returns a Float
    initial_year = game_data["date"] / 1
    initial_date = initial_year * calendar.days_in_month * calendar.months_in_year

    time_left = Core.Tick.millisecond_to_unit_time(game_data["time_limit"] * 60 * 1000, speed.factor)

    # victory points
    victory_points = game_data["victory_points"]

    # Spawn time manager
    data = Instance.Time.Time.new(initial_date, calendar.ut_to_day_factor, metadata[:speed], instance_id)
    channel = "instance:global:#{instance_id}"
    state = Core.GenState.new(:time, instance_id, :master, data, channel)
    DynamicSupervisor.start_child(supervisor_pid, {Instance.Time.Agent, state: state})

    # Spawn rand manager
    data = Instance.Rand.Rand.new(metadata[:seed])
    channel = ""
    state = Core.GenState.new(:rand, instance_id, :master, data, channel)
    DynamicSupervisor.start_child(supervisor_pid, {Instance.Rand.Agent, state: state})

    # Spawn character market manager
    data = Instance.CharacterMarket.CharacterMarket.new(instance_id)
    channel = "instance:global:#{instance_id}"
    state = Core.GenState.new(:character_market, instance_id, :master, data, channel)
    DynamicSupervisor.start_child(supervisor_pid, {Instance.CharacterMarket.Agent, state: state})

    user_broadcast(progress_channel, :step_5, instance_id)

    # prepare stellar systems
    systems =
      Stream.flat_map(game_data["sectors"], fn sector ->
        sector["systems"]
        |> Stream.with_index()
        |> Stream.map(fn {system, idx} ->
          {idx, system, sector["key"], instance_id}
        end)
        |> Enum.to_list()
      end)
      |> Task.async_stream(fn {_idx, system, sector_key, instance_id} ->
        Instance.StellarSystem.StellarSystem.new(system, sector_key, instance_id)
      end)
      |> Stream.map(fn {:ok, result} -> result end)
      |> Enum.to_list()

    # count inhabitable systems
    inhabitable_systems =
      Enum.reduce(systems, 0, fn system, acc ->
        if system.status === :uninhabitable,
          do: acc,
          else: acc + 1
      end)

    user_broadcast(progress_channel, :step_6, instance_id)

    # prepare factions
    factions = Enum.map(instance.factions, fn faction -> Instance.Faction.Faction.new(faction, instance_id) end)

    # prepare players
    players =
      Stream.flat_map(instance.factions, fn faction ->
        Enum.map(faction.registrations, fn registration ->
          Instance.Player.Player.new(registration.profile, faction, instance_id, registration.id)
        end)
      end)
      |> Enum.to_list()

    # SPAWN STEP

    user_broadcast(progress_channel, :step_7, instance_id)

    # Spawn galaxy manager
    data = Instance.Galaxy.Galaxy.new(game_data, players, systems, tutorial_id)
    channel = "instance:global:#{instance_id}"
    state = Core.GenState.new(:galaxy, instance_id, :master, data, channel)
    sectors = data.sectors
    DynamicSupervisor.start_child(supervisor_pid, {Instance.Galaxy.Agent, state: state})

    # Spawn victory manager
    data = Instance.Victory.Victory.new(time_left, victory_points, inhabitable_systems, sectors, factions, instance_id)
    channel = "instance:global:#{instance_id}"
    state = Core.GenState.new(:victory, instance_id, :master, data, channel)
    DynamicSupervisor.start_child(supervisor_pid, {Instance.Victory.Agent, state: state})

    user_broadcast(progress_channel, :step_8, instance_id)

    # Spawn faction
    Enum.each(factions, fn faction ->
      channel = "instance:faction:#{instance_id}:#{faction.id}"
      state = Core.GenState.new(:faction, instance_id, faction.id, faction, channel)
      DynamicSupervisor.start_child(supervisor_pid, {Instance.Faction.Agent, state: state})
    end)

    # Spawn action_orchestrator manager
    data = Instance.ActionOrchestrator.ActionOrchestrator.new(instance_id)
    channel = ""
    state = Core.GenState.new(:action_orchestrator, instance_id, :master, data, channel)
    DynamicSupervisor.start_child(supervisor_pid, {Instance.ActionOrchestrator.Agent, state: state})

    user_broadcast(progress_channel, :step_9, instance_id)

    # Spawn player
    Enum.each(players, fn player ->
      create_player(supervisor_pid, instance_id, player)
    end)

    # Spawn stellar system
    user_broadcast(progress_channel, :step_10, instance_id)

    systems
    |> Task.async_stream(fn system ->
      state = Core.GenState.new(:stellar_system, instance_id, system.id, system, nil)
      DynamicSupervisor.start_child(supervisor_pid, {Instance.StellarSystem.Agent, state: state})
    end)
    |> Stream.run()

    # RELATION STEP
    user_broadcast(progress_channel, :step_11, instance_id)

    players
    |> Enum.each(fn player ->
      # affect player to faction
      Game.call(instance_id, :faction, player.faction_id, {:add_player, player})

      # affect player to stellar system
      Game.call(instance_id, :player, player.id, :claim_initial_system)
    end)

    user_broadcast(progress_channel, :step_12, instance_id)

    {:ok, :instantiated}
  end

  defp create_snapshot(instance_id) do
    with instance when not is_nil(instance) <- RC.Instances.get_instance(instance_id),
         true <- created?(instance_id),
         {:ok, snapshot} <- make_snapshot(instance_id),
         filename = generate_snapshot_filename(instance_id),
         {:ok, file_size} <- Util.Storage.store(snapshot, filename),
         snapshot = %{name: filename, size: file_size, instance_id: instance_id},
         {:ok, %RC.Instances.InstanceSnapshot{} = instance_snapshot} <- RC.InstanceSnapshots.insert(snapshot) do
      {:ok, instance_snapshot}
    else
      false ->
        {:error, :instance_not_instantiated}

      nil ->
        {:error, :instance_not_found}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp init_from_snapshot(supervisor_pid, instance_id, snapshot) do
    Portal.Controllers.GlobalChannel.broadcast_change("instance:global:#{instance_id}", %{signal: :close_game})

    # setup instance data storage
    metadata = List.first(Keyword.get_values(snapshot.instance_data, :metadata))
    Data.Data.insert(instance_id, metadata)

    # setup processes
    Enum.each(snapshot.agents_data, fn %{module: module, state: state} ->
      if module == Spatial.Supervisor do
        Kernel.node(supervisor_pid)
        |> :rpc.call(Spatial, :load, [state, instance_id])
      else
        DynamicSupervisor.start_child(supervisor_pid, {module, state: state})
      end
    end)

    {:ok, :instantiated}
  end

  defp start(instance_id, supervisor_pid) do
    {:ok, time_pid} = Game.get_pid({instance_id, :time, :master})
    {:ok, %Instance.Time.Time{} = time} = GenServer.call(time_pid, :get_state)

    cumulated_pauses = Instance.Time.Time.compute_cumulated_pauses(time)

    stream =
      DynamicSupervisor.which_children(supervisor_pid)
      |> Enum.reject(fn {_, _, _, [module | _]} -> Enum.member?(@no_tick, module) end)
      |> Task.async_stream(
        fn {_, child_pid, _, _} ->
          :ok = GenServer.call(child_pid, {:start, cumulated_pauses})
        end,
        timeout: 30_000
      )

    started = Enum.to_list(stream)

    {:ok, :started, length(started)}
  end

  defp stop(supervisor_pid) do
    stream =
      DynamicSupervisor.which_children(supervisor_pid)
      |> Enum.reject(fn {_, _, _, [module | _]} -> Enum.member?(@no_tick, module) end)
      |> Task.async_stream(fn {_, child_pid, _, _} -> GenServer.call(child_pid, :stop) end, timeout: 30_000)

    stopped = Enum.to_list(stream)

    {:ok, :stopped, length(stopped)}
  end

  # Create an instance: create its supervisor with a child manager
  defp create(instance_id, channel \\ nil) do
    supervisor = {Instance.Supervisor, id: instance_id, shutdown: 10_000}

    # @no_tick GenServers
    manager = {Instance.Manager, id: instance_id}

    spatial =
      {Spatial.Supervisor, [id: instance_id, name: Spatial.get_name(instance_id), width: 6, verbose: false, seed: 0]}

    with {:ok, supervisor_pid} <- Horde.DynamicSupervisor.start_child(Game.Supervisor, supervisor),
         user_broadcast(channel, :step_1, instance_id),
         Process.sleep(500),
         {:ok, _manager_pid} <- DynamicSupervisor.start_child(supervisor_pid, manager),
         user_broadcast(channel, :step_2, instance_id),
         {:ok, _spatial_pid} <- DynamicSupervisor.start_child(supervisor_pid, spatial),
         user_broadcast(channel, :step_3, instance_id) do
      {:ok, supervisor_pid}
    else
      err -> {:error, err}
    end
  end

  defp create_player(supervisor_pid, instance_id, player) do
    channel = "instance:player:#{instance_id}:#{player.id}"
    state = Core.GenState.new(:player, instance_id, player.id, player, channel)
    DynamicSupervisor.start_child(supervisor_pid, {Instance.Player.Agent, state: state})
  end

  defp add_player(supervisor_pid, instance_id, faction, profile, registration_id) do
    # create player
    player = Instance.Player.Player.new(profile, faction, instance_id, registration_id)
    create_player(supervisor_pid, instance_id, player)

    # affect player
    Game.call(instance_id, :faction, player.faction_id, {:add_player, player})
    Game.call(instance_id, :player, player.id, :claim_initial_system)
    Game.cast(instance_id, :galaxy, :master, {:add_player, player})

    # if instance is running: start
    {:ok, state} = Game.call(instance_id, :time, :master, :get_state)

    if state.is_running do
      cumulated_pauses = Instance.Time.Time.compute_cumulated_pauses(state)
      :ok = Game.call(instance_id, :player, player.id, {:start, cumulated_pauses})
    end

    {:ok}
  end

  defp make_snapshot(instance_id) when is_binary(instance_id),
    do: String.to_integer(instance_id) |> make_snapshot()

  defp make_snapshot(instance_id) do
    # fetch instance data
    instance_data = Data.Data.export(instance_id)
    {:ok, supervisor_pid} = Instance.Supervisor.get_pid(instance_id)

    # fetch processes data
    agents_data =
      DynamicSupervisor.which_children(supervisor_pid)
      |> Enum.reject(fn {_, _, _, [module | _]} -> module == Instance.Manager end)
      |> Task.async_stream(
        fn {_, child_pid, _, [module | _]} ->
          state =
            if module == Spatial.Supervisor,
              do: Spatial.dump(instance_id),
              else: GenServer.call(child_pid, :get_full_state)

          %{module: module, state: state}
        end,
        timeout: 30_000
      )
      |> Enum.map(fn {:ok, data} -> data end)

    {:ok,
     %{
       instance_data: instance_data,
       agents_data: agents_data
     }}
  end

  defp generate_snapshot_filename(instance_id) do
    timestamp = DateTime.to_unix(DateTime.utc_now())
    r = Enum.random(1000..9999)

    "snapshot-#{instance_id}-#{timestamp}#{r}"
  end

  defp user_broadcast(channel, response, instance_id) when is_binary(channel) and is_atom(response) do
    PortalChannel.broadcast_change(channel, %{
      status: response,
      instanceId: instance_id
    })

    Logger.debug("(#{instance_id} string) #{response}")
  end

  defp user_broadcast(_, _, _), do: nil
end
