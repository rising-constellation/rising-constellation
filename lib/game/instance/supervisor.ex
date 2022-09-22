defmodule Instance.Supervisor do
  @moduledoc """
  DynamicSupervisor supervising all processes of a single instance
  """

  use DynamicSupervisor

  require Logger

  @handoff_timeout 3_000

  def start_link(opts \\ []) do
    starter(opts, 20)
  end

  defp starter(_instance_id, 0), do: :ignore

  defp starter(opts, attempts) do
    instance_id = Keyword.get(opts, :id)

    case DynamicSupervisor.start_link(__MODULE__, opts, name: Game.via_tuple({instance_id, :instance_supervisor})) do
      {:ok, pid} ->
        spawn(fn -> continue(instance_id, pid) end)
        {:ok, pid}

      {:error, {:already_started, _pid}} ->
        # when a node dies, the dynamic supervisor of each instance living on this node will stay reachable for a short while
        # so we keep trying to reach it a few times and we either give up (:ignore) or, if we cannot reach it anymore,
        # we start a new dynamic supervisor and hydrate it with the handoff data from the dying node
        Process.sleep(500)
        starter(opts, attempts - 1)
    end
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  defp continue(instance_id, supervisor_pid) do
    saved_states = Data.GenServerState.list(instance_id)

    unless Enum.empty?(saved_states) do
      {:ok, _manager_pid} = DynamicSupervisor.start_child(supervisor_pid, {Instance.Manager, id: instance_id})
      # waiting before hydrating, just to be sure all handoff data had enough time to reach us
      Process.sleep(@handoff_timeout)
    end

    saved_states = Data.GenServerState.list(instance_id)

    unless Enum.empty?(saved_states) do
      saved_states
      |> Enum.each(fn name_tuple ->
        case Data.GenServerState.retrieve_delete(name_tuple) do
          {:ok, %{state: state, module: module}} ->
            if Enum.member?([Spatial.Supervisor, Spatial.Handoff], module) do
              DynamicSupervisor.start_child(supervisor_pid, {module, state})
            else
              DynamicSupervisor.start_child(supervisor_pid, {module, state: state})
            end

          :error ->
            unless elem(name_tuple, 1) == :spatial_handoff do
              Logger.warn("Nothing to restore for #{inspect(name_tuple)}")
            end

            nil
        end
      end)

      Logger.debug("restored #{length(saved_states)} processes")
    end
  end

  def get_pid(instance_id, attempts \\ 1), do: Game.get_pid({instance_id, :instance_supervisor}, attempts)
end
