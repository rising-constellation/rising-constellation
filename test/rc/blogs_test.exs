defmodule RC.BlogTest do
  use RC.DataCase, async: true

  alias RC.Blog
  alias RC.Markdown

  import RC.Fixtures

  @valid_attrs %{
    content_raw: "some content_raw",
    title: "some title",
    slug: "some slug",
    language: "fr",
    picture: "some picture",
    summary_raw: "some summary_raw"
  }
  @update_attrs %{
    content_raw: "some updated content_raw",
    title: "some updated title",
    slug: "some updated slug",
    language: "en",
    picture: "some updated picture",
    summary_raw: "some updated summary_raw"
  }
  @invalid_attrs %{
    title: nil,
    slug: nil,
    content_raw: nil,
    language: nil,
    picture: nil,
    summary_raw: nil
  }

  @category_valid_attrs %{
    name: "some category",
    slug: "some slug",
    language: "fr"
  }

  def post_and_user_fixture(attrs \\ %{}) do
    user = fixture(:user)
    {:ok, category} = Blog.create_category(@category_valid_attrs)

    {:ok, post} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Map.put(:account_id, user.id)
      |> Map.put(:category_id, category.id)
      |> Blog.create_post()

    {post, user}
  end

  describe "posts" do
    alias RC.Blog.Post

    test "list_posts/0 returns all blogs" do
      _ = post_and_user_fixture()

      {:ok, paginated_posts} = Blog.list_posts(%{})

      assert paginated_posts.total_entries == 1
    end

    test "list_posts/0 with filter on id returns chosen blogs" do
      {_post, user} = post_and_user_fixture()

      {:ok, paginated_posts} = Blog.list_posts(%{"account_id" => user.id})

      assert paginated_posts.total_entries == 1
    end

    test "list_posts/0 with filter with wrong id returns no blogs" do
      {_post, user} = post_and_user_fixture()

      {:ok, paginated_posts} = Blog.list_posts(%{"account_id" => user.id * 2})

      assert paginated_posts.total_entries == 0
      assert paginated_posts.entries == []
    end

    test "get_post/1 returns the blog with given id" do
      {post, _user} = post_and_user_fixture()
      assert Blog.get_post(post.id) == post
    end

    test "create_blog/1 with valid data creates a blog" do
      user = fixture(:user)
      {:ok, category} = Blog.create_category(@category_valid_attrs)

      assert {:ok, %Post{} = post} =
               Blog.create_post(
                 @valid_attrs
                 |> Map.put(:account_id, user.id)
                 |> Map.put(:category_id, category.id)
               )

      assert post.content_html == Markdown.render_inline(@valid_attrs.content_raw)
      assert post.content_raw == "some content_raw"
      assert post.language == "fr"
      assert post.picture == "some picture"
      assert post.summary_html == Markdown.render_inline(@valid_attrs.summary_raw)
      assert post.summary_raw == "some summary_raw"
      assert post.slug == Slugger.slugify_downcase(post.title)
    end

    test "create_blog/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      {post, _user} = post_and_user_fixture()
      assert {:ok, %Post{} = post} = Blog.update_post(post, @update_attrs)
      assert post.content_html == Markdown.render_inline(@update_attrs.content_raw)
      assert post.content_raw == "some updated content_raw"
      assert post.language == "en"
      assert post.picture == "some updated picture"
      assert post.summary_html == Markdown.render_inline(@update_attrs.summary_raw)
      assert post.summary_raw == "some updated summary_raw"
      assert post.slug == Slugger.slugify_downcase(@update_attrs.title)
    end

    test "update_post/2 with invalid data returns error changeset" do
      {post, _user} = post_and_user_fixture()
      assert {:error, %Ecto.Changeset{}} = Blog.update_post(post, @invalid_attrs)
      assert post == Blog.get_post(post.id)
    end

    test "delete_post/1 deletes the post" do
      {post, _user} = post_and_user_fixture()
      assert {:ok, %Post{}} = Blog.delete_post(post)
      assert nil == Blog.get_post(post.id)
    end
  end

  describe "comments" do
    alias RC.Blog.Comment

    @valid_attrs %{content_raw: "some content_raw"}
    @update_attrs %{content_raw: "some updated content_raw"}
    @invalid_attrs %{content_raw: nil}

    def comment_fixture(attrs \\ %{}) do
      {post, user} = post_and_user_fixture()

      {:ok, comment} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.put(:post_id, post.id)
        |> Map.put(:account_id, user.id)
        |> Blog.create_comment()

      {comment, post}
    end

    test "list_comments/0 returns all comments" do
      {comment, post} = comment_fixture()
      paginated_comments = Blog.list_comments(post.id)

      assert paginated_comments.total_entries == 1
      assert paginated_comments.entries == [comment]
    end

    test "get_comment!/1 returns the comment with given id" do
      {comment, _post} = comment_fixture()
      assert Blog.get_comment(comment.id) == comment
    end

    test "create_comment/1 with valid data creates a comment" do
      {post, user} = post_and_user_fixture()

      assert {:ok, %Comment{} = comment} =
               Blog.create_comment(
                 @valid_attrs
                 |> Map.put(:account_id, user.id)
                 |> Map.put(:post_id, post.id)
               )

      assert comment.content_html == Markdown.render_inline(@valid_attrs.content_raw)
      assert comment.content_raw == "some content_raw"
    end

    test "create_comment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_comment(@invalid_attrs)
    end

    test "update_comment/2 with valid data updates the comment" do
      {comment, _post} = comment_fixture()
      assert {:ok, %Comment{} = comment} = Blog.update_comment(comment, @update_attrs)
      assert comment.content_html == Markdown.render_inline(@update_attrs.content_raw)
      assert comment.content_raw == "some updated content_raw"
    end

    test "update_comment/2 with invalid data returns error changeset" do
      {comment, _post} = comment_fixture()
      assert {:error, %Ecto.Changeset{}} = Blog.update_comment(comment, @invalid_attrs)
      assert comment == Blog.get_comment(comment.id)
    end

    test "delete_comment/1 deletes the comment" do
      {comment, _post} = comment_fixture()
      assert {:ok, %Comment{}} = Blog.delete_comment(comment)
      assert Blog.get_comment(comment.id) == nil
    end
  end

  describe "blog_categories" do
    alias RC.Blog.Category

    @update_attrs %{name: "some updated name", slug: "some updated slug", language: "en"}
    @invalid_attrs %{name: nil, slug: nil, language: nil}

    test "list_blog_categories/0 returns all blog_categories" do
      category = category_fixture()
      {:ok, paginated_categories} = Blog.list_categories(%{})

      assert paginated_categories.total_entries == 1
      assert paginated_categories.entries == [category]
    end

    test "list_blog_categories/0 returns no blog_categories if wrong language" do
      category_fixture()

      {:ok, paginated_categories} = Blog.list_categories(%{"language" => "xx"})

      assert paginated_categories.total_entries == 0
      assert paginated_categories.entries == []
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Blog.get_category(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      assert {:ok, %Category{} = category} = Blog.create_category(blog_category_valid_attrs())
      assert category.name == "some name"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      assert {:ok, %Category{} = category} = Blog.update_category(category, @update_attrs)
      assert category.name == "some updated name"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Blog.update_category(category, @invalid_attrs)
      assert category == Blog.get_category(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Blog.delete_category(category)
      assert Blog.get_category(category.id) == nil
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Blog.change_category(category)
    end
  end
end
