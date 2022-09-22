defmodule Portal.EditArticleLive do
  use Portal, :admin_live_view

  alias RC.Blog

  @impl true
  def handle_params(params, _, socket) do
    post = Blog.get_post(Map.get(params, "pid"))

    categories =
      RC.Repo.all(RC.Blog.Category)
      |> Enum.map(fn cat -> {cat.name, cat.id} end)

    if post != nil do
      {:noreply, assign(socket, post: post, categories: categories)}
    else
      IO.inspect("post not found")
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("update", %{"post" => new_post}, socket) do
    with post when not is_nil(post) <- Blog.get_post(Map.get(new_post, "id")),
         {:ok, _post} <- Blog.update_post(post, new_post) do
      {:noreply, push_redirect(socket, to: Routes.live_path(socket, Portal.ArticlesLive))}
    else
      reason ->
        IO.inspect(reason)
        {:noreply, socket}
    end
  end
end
