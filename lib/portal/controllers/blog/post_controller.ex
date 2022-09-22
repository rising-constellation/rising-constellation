defmodule Portal.Blog.PostController do
  @moduledoc """
  The Blog Post controller.

  API:

  Create a Post:
      POST /blog/posts, body: %{title: ..., content_raw: ..., language: ..., picture: ..., summary_raw: ..., category: ...}
  Get all post with optionals filters (language, account_id, category_id, order_by):
      GET /blog/posts
  Get specific Post:
      GET /blog/posts/:bpid
  Get a specific Post with raw content (for updates):
      GET /blog/posts/:bpid/raw
  Update a Post:
      PUT /blog/posts/:bpid, body: update_params
  Delete a Post:
      DELETE /blog/posts/:bpid
  """
  use Portal, :controller

  alias RC.Blog
  alias RC.Blog.Post

  require Logger

  action_fallback(Portal.FallbackController)

  @valid_order_by_attrs ~w(asc desc)s

  def index(conn, params) do
    case validate_order_by(params) do
      {:ok, order_by, params} ->
        {:ok, posts} = Blog.list_posts(params, order_by)

        conn
        |> Scrivener.Headers.paginate(posts)
        |> render("index.json", posts: posts)

      error ->
        error
    end
  end

  def create(conn, %{
        "post" => post_params
      }) do
    with {:ok, %Post{} = post} <- Blog.create_post(post_params) do
      conn
      |> put_status(:created)
      |> render("show.json", post: post)
    end
  end

  def show(conn, %{"bpid" => id}) do
    case Blog.get_post(id) do
      nil ->
        {:error, :not_found}

      post ->
        render(conn, "show.json", post: post)
    end
  end

  def show_raw(conn, %{"bpid" => id}) do
    case Blog.get_post(id) do
      nil ->
        {:error, :not_found}

      post ->
        render(conn, "show_update.json", post: post)
    end
  end

  def update(conn, %{"bpid" => id, "post" => post_params}) do
    with post when not is_nil(post) <- Blog.get_post(id),
         {:ok, %Post{} = post} <- Blog.update_post(post, post_params) do
      render(conn, "show.json", post: post)
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  def delete(conn, %{"bpid" => id}) do
    with post when not is_nil(post) <- Blog.get_post(id),
         {:ok, %Post{} = _post} <- Blog.delete_post(post) do
      send_resp(conn, :no_content, "")
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  defp validate_order_by(params) do
    if Map.has_key?(params, "order_by") do
      if params["order_by"] in @valid_order_by_attrs,
        do: {:ok, String.to_existing_atom(params["order_by"]), Map.drop(params, ["order_by"])},
        else: {:error, :bad_order_by_param}
    else
      {:ok, :desc, params}
    end
  end
end
