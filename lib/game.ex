defmodule Game do
  use Supervisor

  require Logger

  @self __MODULE__

  def start_link(_opts) do
    Supervisor.start_link(@self, :ok, name: @self)
  end

  @impl true
  def init(:ok) do
    spawn(fn -> Portal.Config.init_config() end)
    Supervisor.init(child_spec_list(), strategy: :one_for_one, shutdown: 10_000)
  end

  def child_spec_list do
    [
      {Horde.Registry, name: Game.Registry, keys: :unique, members: :auto, shutdown: 60_000},
      {Horde.DynamicSupervisor,
       [
         name: Game.Supervisor,
         strategy: :one_for_one,
         distribution_strategy: Horde.UniformQuorumDistribution,
         shutdown: 10_000,
         members: :auto
       ]},
      %{
        id: Game.ClusterConnector,
        restart: :transient,
        start: {Task, :start_link, [fn -> Horde.DynamicSupervisor.wait_for_quorum(Game.Supervisor, 30_000) end]}
      }
    ]
    |> maybe_start_cluster_supervisor(Application.get_env(:rc, :environment))
  end

  def get_pid(_, attempts \\ 0)

  def get_pid(name_tuple, attempts) do
    result = Horde.Registry.lookup(Game.Registry, name_tuple)

    cond do
      length(result) > 0 ->
        [{pid, _} | _] = result
        {:ok, pid}

      attempts > 1 ->
        Process.sleep(200)
        get_pid(name_tuple, attempts - 1)

      true ->
        {:error, :process_not_found}
    end
  end

  @doc """
  TODO
  """
  def call(instance_atom, :rand, :master, action) when is_atom(instance_atom) do
    state = %{data: %{rand_state: :rand.seed(:exrop)}}
    {_, result, _} = Instance.Rand.Agent.on_call(action, nil, state)

    result
  end

  def call(instance_atom, _type, _agent_id, _action) when is_atom(instance_atom) do
    Logger.error("module not available in virtual instance")
    {:error, :process_not_found}
  end

  @doc """
  Call the pid for eg. `{12, :stellar_system, 44}` (instance 12, StellarSystem.Agent, id 44) with
  action = action. Log when process not found. Defaults to only 1 attempt at getting the PID.
  """
  def call(instance_id, type, agent_id, action, attempts \\ 2) do
    do_call(instance_id, type, agent_id, action, true, attempts)
  end

  @doc """
  Same as `Game.call/4` but does *not* log when process not found.
  """
  def call_no_log(instance_id, type, agent_id, action, attempts \\ 2) do
    do_call(instance_id, type, agent_id, action, false, attempts)
  end

  defp do_call(instance_id, type, agent_id, action, log_failure, attempts) do
    case get_pid({instance_id, type, agent_id}, attempts) do
      {:ok, _pid} ->
        GenServer.call(via_tuple({instance_id, type, agent_id}), action)

      {:error, :process_not_found} ->
        if log_failure do
          Logger.error("process_not_found in call",
            instance_id: instance_id,
            type: type,
            agent_id: agent_id,
            action: action
          )
        end

        :process_not_found
    end
  end

  def cast(instance_id, type, agent_id, action) do
    case get_pid({instance_id, type, agent_id}) do
      {:ok, _pid} ->
        GenServer.cast(via_tuple({instance_id, type, agent_id}), action)

      {:error, :process_not_found} ->
        Logger.error("process_not_found in cast",
          instance_id: instance_id,
          type: type,
          agent_id: agent_id,
          action: action
        )

        :process_not_found
    end
  end

  def via_tuple(name) do
    {:via, Horde.Registry, {Game.Registry, name}}
  end

  defp maybe_start_cluster_supervisor(children, :test), do: children

  defp maybe_start_cluster_supervisor(children, _) do
    [{RC.ClusterSupervisor, Application.get_env(:libcluster, :topologies)} | children]
  end
end
