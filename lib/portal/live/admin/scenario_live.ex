defmodule Portal.ScenarioLive do
  use Portal, :admin_live_view

  require Logger

  alias RC.Scenarios

  @impl true
  def handle_params(params, _, socket) do
    scenario = Scenarios.get_scenario(Map.get(params, "sid"))

    if scenario != nil do
      {:noreply, assign(socket, scenario: scenario)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("update", params, socket) do
    scenario = Scenarios.get_scenario(Map.get(params, "scenario"))

    case Scenarios.update_scenario(scenario, params) do
      {:ok, scenario} ->
        scenario = Scenarios.get_scenario(scenario.id)
        {:noreply, assign(socket, scenario: scenario)}

      {:error, _} ->
        IO.inspect("scenario not found")
        {:noreply, socket}
    end
  end
end
