defmodule Portal.CategoriesLive do
  use Portal, :admin_live_view

  alias RC.Blog

  @impl true
  def handle_params(params, _, socket) do
    params = Map.put(%{}, "page", Map.get(params, "page", nil))
    {:noreply, assign(socket, get_and_assign_page(params))}
  end

  @impl true
  def handle_event("new", %{"category" => category}, socket) do
    category =
      category
      |> Map.put("language", "fr")

    Blog.create_category(category)

    {:noreply, assign(socket, get_and_assign_page())}
  end

  @impl true
  def handle_event("delete", %{"cid" => cid}, socket) do
    Blog.get_category(cid)
    |> Blog.delete_category()

    {:noreply, assign(socket, get_and_assign_page())}
  end

  defp get_and_assign_page,
    do: get_and_assign_page(Map.put(%{}, "page", nil))

  defp get_and_assign_page(params) do
    %{
      entries: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    } =
      case Blog.list_categories(params) do
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
      categories: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    ]
  end
end
