defmodule Portal.AccountsLive do
  use Portal, :admin_live_view

  alias RC.Accounts

  @impl true
  def handle_params(params, _, socket) do
    params = Map.put(%{}, "page", Map.get(params, "page", nil))
    assigns = get_and_assign_page(params, nil)
    {:noreply, assign(socket, assigns)}
  end

  @impl true
  def handle_event("search_account", %{"search" => %{"search" => search}}, socket) do
    assigns = get_and_assign_page(%{}, search)
    {:noreply, assign(socket, assigns)}
  end

  defp get_and_assign_page(params, search_string) do
    listed_accounts =
      if search_string,
        do: {:ok, Accounts.search_accounts(params, search_string)},
        else: Accounts.list_accounts(params, false)

    %{
      entries: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    } =
      case listed_accounts do
        {:ok, result} ->
          result

        _result ->
          %{
            entries: [],
            page_number: 0,
            page_size: 0,
            total_entries: 0,
            total_pages: 0
          }
      end

    [
      users: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages,
      search: search_string
    ]
  end
end
