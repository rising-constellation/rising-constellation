defmodule Portal.KeysLive do
  use Portal, :admin_live_view

  alias RC.Store

  @impl true
  def handle_params(params, _, socket) do
    params = Map.put(%{}, "page", Map.get(params, "page", nil))

    socket =
      socket
      |> assign(status: :available)
      |> assign(params: params)

    {:noreply, assign(socket, get_and_assign_page(socket.assigns))}
  end

  @impl true
  def handle_event("add_keys", %{"keys" => %{"keys" => keys}}, socket) do
    keys
    |> String.split(~r/\R/)
    |> Enum.each(fn key -> Store.add_steam_key(key) end)

    {:noreply, assign(socket, get_and_assign_page(socket.assigns))}
  end

  @impl true
  def handle_event("show_available", _, socket) do
    socket = assign(socket, status: :available)
    {:noreply, assign(socket, get_and_assign_page(socket.assigns))}
  end

  @impl true
  def handle_event("show_unavailable", _, socket) do
    socket = assign(socket, status: :unavailable)
    {:noreply, assign(socket, get_and_assign_page(socket.assigns))}
  end

  defp get_and_assign_page(assigns) do
    %{
      entries: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    } = Store.list_steam_keys(assigns.status, assigns.params)

    [
      keys: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    ]
  end
end
