defmodule Portal.Blog.CommentControllerTest do
  use Portal.APIConnCase, async: true

  alias RC.Blog
  alias RC.Blog.Comment
  alias RC.Markdown
  alias RC.Repo

  import RC.Fixtures

  @create_attrs %{
    content_html: "some content_html",
    content_raw: "some content_raw"
  }
  @update_attrs %{
    content_html: "some updated content_html",
    content_raw: "some updated content_raw"
  }
  @invalid_attrs %{content_html: nil, content_raw: nil}

  def fixture_comment() do
    {post, admin, user, user_author} = post_fixture()

    {:ok, comment} =
      Blog.create_comment(
        @create_attrs
        |> Map.put(:post_id, post.id)
        |> Map.put(:account_id, user.id)
      )

    {comment, post, admin, user, user_author}
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_post]

    test "lists all blog_comments", %{conn: conn, post: post} do
      conn = get(conn, Routes.comment_path(conn, :index, post.id))

      assert conn.assigns.comments.total_entries == 0
      assert json_response(conn, 200) == []
    end
  end

  describe "create blog_comment" do
    setup [:create_post]

    test "renders blog_comment when data is valid", %{conn: conn, user: user, post: post} do
      conn =
        conn
        |> login(user)
        |> post(Routes.comment_path(conn, :create, post.id), content_raw: @create_attrs.content_raw)

      assert comment = json_response(conn, 201)

      conn =
        build_conn()
        |> login(user)
        |> get(Routes.comment_path(conn, :index, post.id))

      assert [post_comment] = json_response(conn, 200)
      assert post_comment == comment
      assert comment["content_html"] == Markdown.render_inline(@create_attrs.content_raw)
    end

    test "renders error when invalid attributes", %{conn: conn, post: post, user: user} do
      conn =
        conn
        |> login(user)
        |> post(Routes.comment_path(conn, :create, post.id), content_raw: nil)

      assert json_response(conn, 400)["message"]["content_raw"] == ["can't be blank"]
    end

    test "renders unauthenticated when not logged in", %{conn: conn, post: post} do
      conn = post(conn, Routes.comment_path(conn, :create, post.id), blog_comment: @invalid_attrs)
      assert json_response(conn, 401)["message"] == "unauthenticated"
    end
  end

  describe "show" do
    setup [:create_blog_comment]

    test "renders blog_comment when own comment", %{
      conn: conn,
      comment: comment,
      user: user
    } do
      conn =
        build_conn()
        |> login(user)
        |> get(Routes.comment_path(conn, :show, comment.id))

      assert comment_json = json_response(conn, 200)
      assert comment_json["content_html"] == Markdown.render_inline(comment.content_raw)
      assert comment_json["content_raw"] == comment.content_raw
      assert comment_json["id"] == comment.id
    end

    test "renders blog_comment when admin", %{
      conn: conn,
      comment: comment,
      admin: admin
    } do
      conn =
        build_conn()
        |> login(admin)
        |> get(Routes.comment_path(conn, :show, comment.id))

      assert comment_json = json_response(conn, 200)
      assert comment_json["content_html"] == Markdown.render_inline(comment.content_raw)
      assert comment_json["content_raw"] == comment.content_raw
      assert comment_json["id"] == comment.id
    end

    test "returns unauthorized access when not own comment", %{
      conn: conn,
      comment: comment,
      user_author: user_author
    } do
      conn =
        conn
        |> login(user_author)
        |> get(Routes.comment_path(conn, :show, comment.id))

      assert json_response(conn, 403)["message"] == "forbidden"
    end
  end

  describe "update blog_comment" do
    setup [:create_blog_comment]

    test "renders blog_comment when data is valid and own comment", %{
      conn: conn,
      post: post,
      comment: comment,
      user: user
    } do
      conn =
        conn
        |> login(user)
        |> put(Routes.comment_path(conn, :update, comment.id), content_raw: @update_attrs.content_raw)

      assert comment = json_response(conn, 200)

      conn =
        build_conn()
        |> login(user)
        |> get(Routes.comment_path(conn, :index, post.id))

      assert [post_comment] = json_response(conn, 200)
      assert post_comment == comment
      assert comment["content_html"] == Markdown.render_inline(@update_attrs.content_raw)
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      comment: comment,
      user: user
    } do
      conn =
        conn
        |> login(user)
        |> put(Routes.comment_path(conn, :update, comment.id), content_raw: nil)

      assert json_response(conn, 400)["message"]["content_raw"] == ["can't be blank"]
    end

    test "returns unauthorized access when not own comment", %{
      conn: conn,
      comment: comment,
      user_author: user_author
    } do
      conn =
        conn
        |> login(user_author)
        |> put(Routes.comment_path(conn, :update, comment.id), content_raw: nil)

      assert json_response(conn, 403)["message"] == "forbidden"
    end
  end

  describe "delete blog_comment" do
    setup [:create_blog_comment]

    test "deletes chosen blog_comment", %{conn: conn, comment: comment, user: user} do
      conn =
        conn
        |> login(user)
        |> delete(Routes.comment_path(conn, :delete, comment))

      assert response(conn, 204)
      assert Repo.all(Comment) == []
    end

    test "as admin deletes any blog_comment", %{conn: conn, comment: comment, admin: admin} do
      conn =
        conn
        |> login(admin)
        |> delete(Routes.comment_path(conn, :delete, comment))

      assert response(conn, 204)
      assert Repo.all(Comment) == []
    end

    test "returns unauthorized access when not own comment", %{conn: conn, comment: comment, user_author: user_author} do
      conn =
        conn
        |> login(user_author)
        |> delete(Routes.comment_path(conn, :delete, comment))

      assert json_response(conn, 403)["message"] == "forbidden"
    end
  end

  defp create_blog_comment(_) do
    {comment, post, admin, user, user_author} = fixture_comment()
    {:ok, comment: comment, user: user, post: post, admin: admin, user_author: user_author}
  end
end
