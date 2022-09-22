defmodule Portal.MapsLive do
  use Portal, :admin_live_view

  require Logger

  alias RC.Scenarios

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, %{filters: Scenarios.Map, show_filters: false})}
  end

  @impl true
  def handle_params(params, _, socket) do
    maps = get_and_assign_page(params)
    {:noreply, assign(socket, maps)}
  end

  @impl true
  def handle_event("filter", %{"Elixir.RC.Scenarios.Map" => filters} = params, socket) do
    params = Map.put(%{}, "page", Map.get(params, "page", nil))

    filters =
      Enum.reduce(filters, %{}, fn {key, val}, acc ->
        case val do
          "" -> acc
          val -> Map.put(acc, key, val)
        end
      end)

    assigns = Map.merge(params, filters) |> get_and_assign_page()
    {:noreply, assign(socket, assigns)}
  end

  @impl true
  def handle_event("toggle_filters", _params, socket) do
    {:noreply, assign(socket, show_filters: !socket.assigns.show_filters)}
  end

  defp get_and_assign_page(params) do
    %{
      entries: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    } = Scenarios.list_maps(params)

    [
      maps: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    ]
  end
end
