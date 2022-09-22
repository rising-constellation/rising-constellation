defmodule Portal.GroupsLive do
  use Portal, :admin_live_view

  alias RC.Groups

  @impl true
  def handle_params(params, _, socket) do
    params = Map.put(%{}, "page", Map.get(params, "page", nil))
    {:noreply, assign(socket, get_and_assign_page(params))}
  end

  @impl true
  def handle_event("new", %{"group" => group}, socket) do
    Groups.create_group(group)
    {:noreply, assign(socket, get_and_assign_page(%{page: nil}))}
  end

  @impl true
  def handle_event("delete", %{"gid" => gid}, socket) do
    Groups.get_group(gid)
    |> Groups.delete_group()

    {:noreply, assign(socket, get_and_assign_page(%{page: nil}))}
  end

  defp get_and_assign_page(params) do
    %{
      entries: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    } = Groups.list_groups(params)

    [
      groups: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    ]
  end
end
