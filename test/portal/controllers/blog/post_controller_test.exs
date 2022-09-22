defmodule Portal.Blog.PostControllerTest do
  use Portal.APIConnCase, async: true

  alias RC.Blog.Post
  alias RC.Repo
  alias RC.Markdown

  import RC.Fixtures

  # user -> standard user
  # user2 -> blog author

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_post]

    test "lists all blogs with descending order by default", %{conn: conn, post: post} do
      conn = get(conn, Routes.post_path(conn, :index))

      # no content_html in index
      assert conn.assigns.posts.total_entries == 1

      assert [
               %{
                 "id" => post.id,
                 "language" => "fr",
                 "picture" => "some picture",
                 "summary_html" => Markdown.render_inline(blog_post_valid_attrs().summary_raw),
                 "title" => "some title",
                 "slug" => Slugger.slugify_downcase(blog_post_valid_attrs().title)
               }
             ] == json_response(conn, 200)
    end

    test "lists all blogs with ascending order by", %{conn: conn, post: post} do
      conn = get(conn, Routes.post_path(conn, :index), order_by: "asc")

      # no content_html in index
      assert conn.assigns.posts.total_entries == 1

      assert [
               %{
                 "id" => post.id,
                 "language" => "fr",
                 "picture" => "some picture",
                 "summary_html" => Markdown.render_inline(blog_post_valid_attrs().summary_raw),
                 "title" => "some title",
                 "slug" => Slugger.slugify_downcase(blog_post_valid_attrs().title)
               }
             ] == json_response(conn, 200)
    end

    test "lists no blogs if wrong id on filter", %{conn: conn, user: user} do
      conn = get(conn, Routes.post_path(conn, :index), %{account_id: user.id * 2})

      # no content_html in index
      assert conn.assigns.posts.total_entries == 0
      assert json_response(conn, 200) == []
    end
  end

  describe "create blog" do
    setup [:create_group]

    test "renders blog when data is valid when admin", %{conn: conn, admin: admin} do
      category = category_fixture()

      conn =
        conn
        |> login(admin)
        |> post(Routes.post_path(conn, :create),
          post:
            blog_post_valid_attrs()
            |> Map.put(:account_id, admin.id)
            |> Map.put(:category_id, category.id)
        )

      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, Routes.post_path(conn, :show, id))

      assert %{
               "id" => id,
               "title" => "some title",
               "slug" => Slugger.slugify_downcase(blog_post_valid_attrs().title),
               "content_html" => Markdown.render_inline(blog_post_valid_attrs().content_raw),
               "language" => "fr",
               "picture" => "some picture",
               "summary_html" => Markdown.render_inline(blog_post_valid_attrs().summary_raw)
             } == json_response(conn, 200)
    end

    test "renders blog when data is valid when blog author", %{conn: conn, user_author: user_author} do
      category = category_fixture()

      conn =
        conn
        |> login(user_author)
        |> post(Routes.post_path(conn, :create),
          post:
            blog_post_valid_attrs()
            |> Map.put(:account_id, user_author.id)
            |> Map.put(:category_id, category.id)
        )

      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, Routes.post_path(conn, :show, id))

      assert %{
               "id" => id,
               "title" => "some title",
               "slug" => Slugger.slugify_downcase(blog_post_valid_attrs().title),
               "content_html" => Markdown.render_inline(blog_post_valid_attrs().content_raw),
               "language" => "fr",
               "picture" => "some picture",
               "summary_html" => Markdown.render_inline(blog_post_valid_attrs().summary_raw)
             } == json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, admin: admin} do
      conn =
        conn
        |> login(admin)
        |> post(Routes.post_path(conn, :create),
          post:
            blog_post_invalid_attrs()
            |> Map.put(:account_id, nil)
            |> Map.put(:category_id, nil)
        )

      assert json_response(conn, 400)["errors"] != %{}
    end

    test "returns forbidden when not admin or blog author", %{conn: conn, user: user} do
      category = category_fixture()

      conn =
        conn
        |> login(user)
        |> post(Routes.post_path(conn, :create),
          post:
            blog_post_valid_attrs()
            |> Map.put(:account_id, user.id)
            |> Map.put(:category_id, category.id)
        )

      assert json_response(conn, 403)["message"] == "forbidden"
    end
  end

  describe "update post" do
    setup [:create_post]

    test "renders updated blog when data is valid when admin", %{conn: conn, post: %Post{id: id} = post, admin: admin} do
      conn =
        conn
        |> login(admin)
        |> put(Routes.post_path(conn, :update, post), post: blog_post_update_attrs())

      assert %{"id" => ^id} = json_response(conn, 200)

      conn =
        build_conn()
        |> login(admin)
        |> get(Routes.post_path(conn, :show, id))

      updated_summary_html = Markdown.render_inline(blog_post_update_attrs().summary_raw)
      updated_content_html = Markdown.render_inline(blog_post_update_attrs().content_raw)

      assert json_response = json_response(conn, 200)
      assert json_response["content_html"] == updated_content_html
      assert json_response["summary_html"] == updated_summary_html

      assert %{
               "id" => ^id,
               "title" => "some updated title",
               "slug" => expected_slug,
               "language" => "en",
               "picture" => "some updated picture"
             } = json_response

      assert expected_slug == Slugger.slugify(blog_post_update_attrs().title)
    end

    test "renders updated blog when data is valid when blog author", %{
      conn: conn,
      post: %Post{id: id} = post,
      user_author: user_author
    } do
      conn =
        conn
        |> login(user_author)
        |> put(Routes.post_path(conn, :update, post), post: blog_post_update_attrs())

      assert %{"id" => ^id} = json_response(conn, 200)

      conn =
        build_conn()
        |> login(user_author)
        |> get(Routes.post_path(conn, :show, id))

      updated_summary_html = Markdown.render_inline(blog_post_update_attrs().summary_raw)
      updated_content_html = Markdown.render_inline(blog_post_update_attrs().content_raw)

      assert json_response = json_response(conn, 200)
      assert json_response["content_html"] == updated_content_html
      assert json_response["summary_html"] == updated_summary_html

      assert %{
               "id" => ^id,
               "title" => "some updated title",
               "slug" => expected_slug,
               "language" => "en",
               "picture" => "some updated picture"
             } = json_response

      assert expected_slug == Slugger.slugify(blog_post_update_attrs().title)
    end

    test "renders errors when data is invalid", %{conn: conn, post: post, admin: admin} do
      conn =
        conn
        |> login(admin)
        |> put(Routes.post_path(conn, :update, post), post: blog_post_invalid_attrs())

      assert json_response(conn, 400)["message"] == %{
               "content_raw" => ["can't be blank"],
               "language" => ["can't be blank"],
               "picture" => ["can't be blank"],
               "summary_raw" => ["can't be blank"],
               "title" => ["can't be blank"]
             }
    end

    test "returns forbidden when not admin or blog author", %{conn: conn, post: post, user: user} do
      conn =
        conn
        |> login(user)
        |> put(Routes.post_path(conn, :update, post), post: blog_post_update_attrs())

      assert json_response(conn, 403)["message"] == "forbidden"
    end
  end

  describe "delete post" do
    setup [:create_post]

    test "deletes chosen blog when admin", %{conn: conn, post: post, admin: admin} do
      conn =
        conn
        |> login(admin)
        |> delete(Routes.post_path(conn, :delete, post.id))

      assert response(conn, 204)

      assert Repo.all(Post) == []
    end

    test "deletes chosen blog when blog author", %{conn: conn, post: post, user_author: user_author} do
      conn =
        conn
        |> login(user_author)
        |> delete(Routes.post_path(conn, :delete, post.id))

      assert response(conn, 204)

      assert Repo.all(Post) == []
    end

    test "returns forbidden when not admin or blog author", %{conn: conn, post: post, user: user} do
      conn =
        conn
        |> login(user)
        |> delete(Routes.post_path(conn, :delete, post.id))

      assert json_response(conn, 403)["message"] == "forbidden"
    end
  end

  describe "show" do
    setup [:create_post]

    test "shows specific blog", %{conn: conn, post: post} do
      conn = get(conn, Routes.post_path(conn, :show, post.id))

      assert %{
               "id" => post.id,
               "title" => "some title",
               "slug" => Slugger.slugify_downcase(blog_post_valid_attrs().title),
               "content_html" => Markdown.render_inline(blog_post_valid_attrs().content_raw),
               "language" => "fr",
               "picture" => "some picture",
               "summary_html" => Markdown.render_inline(blog_post_valid_attrs().summary_raw)
             } == json_response(conn, 200)
    end
  end

  describe "show update" do
    setup [:create_post]

    test "shows specific blog with content raw when admin", %{conn: conn, post: post, admin: admin} do
      conn =
        conn
        |> login(admin)
        |> get(Routes.post_path(conn, :show_raw, post.id))

      assert %{
               "id" => post.id,
               "title" => "some title",
               "slug" => Slugger.slugify_downcase(blog_post_valid_attrs().title),
               "content_html" => Markdown.render_inline(blog_post_valid_attrs().content_raw),
               "content_raw" => "some content_raw",
               "language" => "fr",
               "picture" => "some picture",
               "summary_html" => Markdown.render_inline(blog_post_valid_attrs().summary_raw),
               "summary_raw" => "some summary_raw"
             } == json_response(conn, 200)
    end

    test "shows specific blog with content raw when blog author", %{
      conn: conn,
      post: post,
      user_author: user_author
    } do
      conn =
        conn
        |> login(user_author)
        |> get(Routes.post_path(conn, :show_raw, post.id))

      assert %{
               "id" => post.id,
               "title" => "some title",
               "slug" => Slugger.slugify_downcase(blog_post_valid_attrs().title),
               "content_html" => Markdown.render_inline(blog_post_valid_attrs().content_raw),
               "content_raw" => "some content_raw",
               "language" => "fr",
               "picture" => "some picture",
               "summary_html" => Markdown.render_inline(blog_post_valid_attrs().summary_raw),
               "summary_raw" => "some summary_raw"
             } == json_response(conn, 200)
    end

    test "returns forbidden when not admin", %{conn: conn, post: post, user: user} do
      conn =
        conn
        |> login(user)
        |> get(Routes.post_path(conn, :show_raw, post.id))

      assert json_response(conn, 403)["message"] == "forbidden"
    end
  end
end
