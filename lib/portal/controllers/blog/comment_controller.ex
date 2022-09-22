defmodule Portal.Blog.CommentController do
  @moduledoc """
  The Blog Comment controller.

  API:

  Get all comments of a specific post:
      GET /blog/posts/:bpid/comments
  Create a Comment for a specific post:
      POST /blog/posts/:bpid/comments
  Get a specific Comment (for update):
      GET /blog/comments/:bcid
  Update a specific Comment:
      PUT /blog/comments/:bcid
  Delete a specific Comment:
      DELETE /blog/comments/:bcid
  """
  use Portal, :controller

  alias RC.Blog
  alias RC.Blog.Comment

  require Logger

  action_fallback(Portal.FallbackController)

  def index(conn, %{"bpid" => bpid}) do
    comments = Blog.list_comments(bpid)

    conn
    |> Scrivener.Headers.paginate(comments)
    |> render("index.json", comments: comments)
  end

  def create(conn, %{"bpid" => bpid, "content_raw" => content_raw}) do
    aid = conn.private.guardian_default_resource.id

    comment_params = %{account_id: aid, post_id: bpid, content_raw: content_raw}

    case Blog.create_comment(comment_params) do
      {:ok, %Comment{} = comment} ->
        conn
        |> put_status(:created)
        |> render("show.json", comment: comment)

      error ->
        error
    end
  end

  # pour update
  def show(conn, %{"bcid" => id}) do
    case Blog.get_comment(id) do
      nil ->
        {:error, :not_found}

      comment ->
        render(conn, "show_update.json", comment: comment)
    end
  end

  def update(conn, %{"bcid" => id, "content_raw" => content_raw}) do
    with comment when not is_nil(comment) <- Blog.get_comment(id),
         {:ok, %Comment{} = comment} <- Blog.update_comment(comment, %{content_raw: content_raw}) do
      render(conn, "show.json", comment: comment)
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  def delete(conn, %{"bcid" => id}) do
    with comment when not is_nil(comment) <- Blog.get_comment(id),
         {:ok, %Comment{}} <- Blog.delete_comment(comment) do
      send_resp(conn, :no_content, "")
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end
end
