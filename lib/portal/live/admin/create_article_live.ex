defmodule Portal.CreateArticleLive do
  use Portal, :admin_live_view

  alias RC.Blog

  @impl true
  def handle_params(_params, _, socket) do
    categories =
      RC.Repo.all(RC.Blog.Category)
      |> Enum.map(fn cat -> {cat.name, cat.id} end)

    {:noreply, assign(socket, categories: categories)}
  end

  @impl true
  def handle_event("new", %{"post" => post}, socket) do
    IO.inspect("new")

    post =
      post
      |> Map.put("language", "fr")
      # TODO
      |> Map.put("picture", "TODO")
      # TODO
      |> Map.put("account_id", 1)

    case Blog.create_post(post) do
      {:ok, _} ->
        {:noreply, push_redirect(socket, to: Routes.live_path(socket, Portal.ArticlesLive))}

      _ ->
        IO.inspect(socket)
        {:noreply, socket}
    end
  end
end
