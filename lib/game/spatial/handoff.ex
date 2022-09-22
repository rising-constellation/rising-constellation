defmodule Spatial.Handoff do
  require Logger

  use GenServer

  def init(opts) do
    Process.flag(:trap_exit, true)
    {:ok, opts, {:continue, :load_state}}
  end

  def handle_continue(:load_state, opts) do
    instance_id = Keyword.get(opts, :id)

    load_state(instance_id)
    {:noreply, opts}
  end

  def terminate(:shutdown, %{kill: true}) do
    # process is terminated by the manager, don't save its state
    :ok
  end

  def terminate(_reason, opts) do
    instance_id = Keyword.get(opts, :id)
    # process is dying, save handoff state
    name_tuple = {instance_id, :spatial_supervisor}
    # Horde.Registry.unregister(Game.Registry, name_tuple)
    Data.GenServerState.save(name_tuple, opts, Spatial.Supervisor)

    name_tuple = {instance_id, :spatial_handoff}
    Horde.Registry.unregister(Game.Registry, name_tuple)
    spatial_data = Spatial.dump(instance_id)
    Data.GenServerState.save(name_tuple, {instance_id, spatial_data}, __MODULE__)

    Process.sleep(10_000)
  end

  def start_link(opts) do
    instance_id = Keyword.get(opts, :id)
    GenServer.start_link(__MODULE__, opts, name: Game.via_tuple({instance_id, :spatial_handoff}))
  end

  defp load_state(instance_id) do
    # try loading handoff data (load it if it's there)
    name_tuple = {instance_id, :spatial_handoff}
    Horde.Registry.register(Game.Registry, name_tuple, self())

    case Data.GenServerState.retrieve_delete(name_tuple) do
      {:ok, %{state: {instance_id, spatial_data}}} ->
        Spatial.load(spatial_data, instance_id)
        true

      :error ->
        false
    end
  end
end
