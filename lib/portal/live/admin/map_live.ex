defmodule Portal.MapLive do
  use Portal, :admin_live_view

  require Logger

  alias RC.Scenarios

  @impl true
  def handle_params(params, _, socket) do
    map = Scenarios.get_map(Map.get(params, "mid"))

    if map != nil do
      {:noreply, assign(socket, map: map)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("update", params, socket) do
    map = Scenarios.get_map(Map.get(params, "mid"))

    case Scenarios.update_map(map, params) do
      {:ok, map} ->
        map = Scenarios.get_map(map.id)
        {:noreply, assign(socket, map: map)}

      {:error, _} ->
        IO.inspect("map not found")
        {:noreply, socket}
    end
  end
end
