defmodule Portal.Blog.CategoryController do
  @moduledoc """
  The Blog Category controller.

  API:

  Get all posts with optional filters:
      GET /blog/categories, body: %{language: ..., account_id: ..., category_id: ..., order_by: "desc"/"asc"}
  Create a Category:
      POST /blog/categories, body: %{name: ..., language: ...}
  Get a specific Category:
      GET /blog/categories/:bcid
  Update a specific Category:
      PUT /blog/categories/:bcid
  Delete a Category:
     DELETE /blog/categories/:bcid
  """

  use Portal, :controller

  alias RC.Blog
  alias RC.Blog.Category

  require Logger

  action_fallback(Portal.FallbackController)

  def index(conn, params) do
    {:ok, categories} = Blog.list_categories(params)

    conn
    |> Scrivener.Headers.paginate(categories)
    |> render("index.json", categories: categories)
  end

  def create(conn, %{"category" => category_params}) do
    case Blog.create_category(category_params) do
      {:ok, %Category{} = category} ->
        conn
        |> put_status(:created)
        |> render("show.json", category: category)

      error ->
        error
    end
  end

  def show(conn, %{"bcid" => id}) do
    case Blog.get_category(id) do
      nil -> {:error, :not_found}
      category -> render(conn, "show.json", category: category)
    end
  end

  def update(conn, %{"bcid" => id, "category" => category_params}) do
    with category when not is_nil(category) <- Blog.get_category(id),
         {:ok, %Category{} = category} <- Blog.update_category(category, category_params) do
      render(conn, "show.json", category: category)
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  def delete(conn, %{"bcid" => id}) do
    with category when not is_nil(category) <- Blog.get_category(id),
         {:ok, %Category{}} <- Blog.delete_category(category) do
      send_resp(conn, :no_content, "")
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end
end
