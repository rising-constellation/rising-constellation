defmodule Portal.Blog.CategoryControllerTest do
  use Portal.APIConnCase, async: true

  alias RC.Blog
  alias RC.Blog.Category
  alias RC.Repo

  import RC.Fixtures

  @create_attrs %{
    name: "some name",
    language: "fr",
    slug: "some slug"
  }
  @update_attrs %{
    name: "some updated name",
    language: "en",
    slug: "some updated slug"
  }
  @invalid_attrs %{name: nil, language: nil, slug: nil}

  def category_and_users_fixture() do
    {admin, user, user_author} = fixture(:blog_writers_group)
    {:ok, blog_category} = Blog.create_category(@create_attrs)
    {blog_category, admin, user, user_author}
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_blog_category_and_users]

    test "as admin lists all blog_categories", %{conn: conn, admin: admin, category: category} do
      conn =
        conn
        |> login(admin)
        |> get(Routes.category_path(conn, :index))

      [json_category | t] = json_response(conn, 200)

      assert conn.assigns.categories.total_entries == 1
      assert t == []
      assert json_category["id"] == category.id
      assert json_category["name"] == category.name
      assert json_category["slug"] == category.slug
      assert json_category["language"] == category.language
    end

    test "as blog writer lists all blog_categories", %{
      conn: conn,
      user_author: user_author,
      category: category
    } do
      conn =
        conn
        |> login(user_author)
        |> get(Routes.category_path(conn, :index))

      [json_category | t] = json_response(conn, 200)

      assert t == []
      assert json_category["id"] == category.id
      assert json_category["name"] == category.name
      assert json_category["slug"] == category.slug
      assert json_category["language"] == category.language
    end

    test "as user lists all blog_categories", %{
      conn: conn,
      user: user,
      category: category
    } do
      conn =
        conn
        |> login(user)
        |> get(Routes.category_path(conn, :index))

      [json_category | t] = json_response(conn, 200)

      assert t == []
      assert json_category["id"] == category.id
      assert json_category["name"] == category.name
      assert json_category["slug"] == category.slug
      assert json_category["language"] == category.language
    end
  end

  describe "create blog_category" do
    setup [:create_group]

    test "as admin renders blog_category when data is valid", %{conn: conn, admin: admin} do
      conn =
        conn
        |> login(admin)
        |> post(Routes.category_path(conn, :create), category: @create_attrs)

      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, Routes.category_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "name" => "some name"
             } = json_response(conn, 200)
    end

    test "as blog author renders blog_category when data is valid", %{conn: conn, user_author: user_author} do
      conn =
        conn
        |> login(user_author)
        |> post(Routes.category_path(conn, :create), category: @create_attrs)

      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, Routes.category_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "name" => "some name"
             } = json_response(conn, 200)
    end

    test "as user returns error", %{conn: conn, user: user} do
      conn =
        conn
        |> login(user)
        |> post(Routes.category_path(conn, :create), category: @create_attrs)

      assert json_response(conn, 403)["message"] == "forbidden"
    end

    test "renders errors when data is invalid", %{conn: conn, admin: admin} do
      conn =
        conn
        |> login(admin)
        |> post(Routes.category_path(conn, :create), category: @invalid_attrs)

      assert json_response(conn, 400)["message"] ==
               %{"language" => ["can't be blank"], "name" => ["can't be blank"]}
    end
  end

  describe "update blog_category" do
    setup [:create_blog_category_and_users]

    test "as admin renders blog_category when data is valid", %{
      conn: conn,
      category: %Category{id: id} = blog_category,
      admin: admin
    } do
      conn =
        conn
        |> login(admin)
        |> put(Routes.category_path(conn, :update, blog_category), category: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, Routes.category_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "name" => "some updated name"
             } = json_response(conn, 200)
    end

    test "as blog writer renders blog_category when data is valid", %{
      conn: conn,
      category: %Category{id: id} = blog_category,
      user_author: user_author
    } do
      conn =
        conn
        |> login(user_author)
        |> put(Routes.category_path(conn, :update, blog_category), category: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, Routes.category_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "name" => "some updated name"
             } = json_response(conn, 200)
    end

    test "as user returns forbidden", %{
      conn: conn,
      category: category,
      user: user
    } do
      conn =
        conn
        |> login(user)
        |> put(Routes.category_path(conn, :update, category), category: @update_attrs)

      assert json_response(conn, 403)["message"] == "forbidden"
    end

    test "renders errors when data is invalid", %{conn: conn, category: category, admin: admin} do
      conn =
        conn
        |> login(admin)
        |> put(Routes.category_path(conn, :update, category), category: @invalid_attrs)

      assert json_response(conn, 400)["message"] == %{"language" => ["can't be blank"], "name" => ["can't be blank"]}
    end
  end

  describe "delete blog_category" do
    setup [:create_blog_category_and_users]

    test "as admin edletes chosen blog_category", %{conn: conn, admin: admin, category: category} do
      conn =
        conn
        |> login(admin)
        |> delete(Routes.category_path(conn, :delete, category))

      assert response(conn, 204)

      assert Repo.all(Category) == []
    end

    test "as blog author deletes chosen blog_category", %{conn: conn, user_author: user_author, category: category} do
      conn =
        conn
        |> login(user_author)
        |> delete(Routes.category_path(conn, :delete, category))

      assert response(conn, 204)

      assert Repo.all(Category) == []
    end

    test "as user returns forbidden", %{conn: conn, user: user, category: category} do
      conn =
        conn
        |> login(user)
        |> delete(Routes.category_path(conn, :delete, category))

      assert json_response(conn, 403)["message"] == "forbidden"
    end
  end

  defp create_blog_category_and_users(_) do
    {category, admin, user, user_author} = category_and_users_fixture()
    {:ok, category: category, admin: admin, user: user, user_author: user_author}
  end
end
