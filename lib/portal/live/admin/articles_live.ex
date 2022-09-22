defmodule Portal.ArticlesLive do
  use Portal, :admin_live_view

  alias RC.Blog

  @impl true
  def handle_params(params, _, socket) do
    params = Map.put(%{}, "page", Map.get(params, "page", nil))
    {:noreply, assign(socket, get_and_assign_page(params))}
  end

  defp get_and_assign_page(params) do
    %{
      entries: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    } =
      case Blog.list_posts(params) do
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
      posts: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    ]
  end
end
