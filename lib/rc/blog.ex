defmodule RC.Blog do
  @moduledoc """
  The Blogs context.
  """

  import Ecto.Query, warn: false
  alias RC.Repo

  alias RC.Blog.Post
  alias RC.Blog.Category
  alias RC.Blog.Comment

  @doc """
  Returns the list of blog posts.

  ## Examples

      iex> list_posts(filter_params)
      [%Post{}, ...]

  """
  def list_posts(params, order_by \\ :desc) do
    filtrex_params = Map.drop(params, ["page"])
    config = Post.filter_options()

    case Filtrex.parse_params(config, filtrex_params) do
      {:ok, filter} ->
        posts =
          if(order_by == :asc,
            do: from(p in Post, order_by: [asc: p.inserted_at], preload: [:account, :category]),
            else: from(p in Post, order_by: [desc: p.inserted_at], preload: [:account, :category])
          )
          |> Filtrex.query(filter)
          |> Repo.paginate(params)

        {:ok, posts}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Gets a single blog post.

  Returns `nil` if the Post does not exist.

  ## Examples

      iex> get_post(123)
      %Blog{}

      iex> get_post(456)
      nil

  """
  def get_post(id), do: Repo.get(Post, id)

  @doc """
  Creates a blog post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a blog post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a blog post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns the list of comments.

  ## Examples

      iex> list_comments(1)
      [%Comment{}, ...]

  """
  def list_comments(post_id) do
    Repo.paginate(
      from(c in Comment,
        where: c.post_id == ^post_id
      )
    )
  end

  @doc """
  Gets a single comment.

  Returns `nil` if the Blog comment does not exist.

  ## Examples

      iex> get_comment(123)
      %Comment{}

      iex> get_comment(456)
      nil

  """
  def get_comment(id), do: Repo.get(Comment, id)

  @doc """
  Creates a comment.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_comment(attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a comment.

  ## Examples

      iex> update_comment(comment, %{field: new_value})
      {:ok, %Comment{}}

      iex> update_comment(comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a comment.

  ## Examples

      iex> delete_comment(comment)
      {:ok, %Comment{}}

      iex> delete_comment(comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  @doc """
  Returns true if a comment is owned by a user.
  """
  def own_comment?(account_id, comment_id) do
    Repo.exists?(
      from(c in Comment,
        where: c.account_id == ^account_id and c.id == ^comment_id
      )
    )
  end

  @doc """
  Returns the list of blog categories.

  ## Examples

      iex> list_categories()
      {:ok, [%Category{}, ...]}

  """
  def list_categories(params) do
    filtrex_params = Map.drop(params, ["page"])
    config = Category.filter_options()

    case Filtrex.parse_params(config, filtrex_params) do
      {:ok, filter} ->
        categories =
          Filtrex.query(Category, filter)
          |> Repo.paginate(params)

        {:ok, categories}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Gets a single category.

  Returns `nil` if the Blog category does not exist.

  ## Examples

      iex> get_category(123)
      %Category{}

      iex> get_category(456)
      nil

  """
  def get_category(id), do: Repo.get(Category, id)

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{source: %Category{}}

  """
  def change_category(%Category{} = category) do
    Category.changeset(category, %{})
  end
end
