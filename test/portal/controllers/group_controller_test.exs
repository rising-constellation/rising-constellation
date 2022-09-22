defmodule Portal.GroupControllerTest do
  use Portal.APIConnCase, async: true

  import RC.Fixtures
  import RC.ScenarioFixtures

  alias RC.Groups.Group

  @create_attrs %{
    name: "some name"
  }

  @invalid_attrs %{name: nil}

  defp build_api_conn() do
    build_conn() |> put_req_header("accept", "application/json")
  end

  describe "create group" do
    test "renders group when data is valid", %{conn: conn} do
      account_user = fixture(:user)
      account_admin = fixture(:admin)

      account_ids = [account_user.id, account_admin.id]

      conn =
        conn
        |> login(account_admin)
        |> post(
          Routes.group_path(conn, :create),
          %{group: @create_attrs}
          |> Map.put(:account_ids, account_ids)
        )

      assert %{"id" => id, "accounts" => [account_user, account_admin]} = json_response(conn, 201)

      conn = get(conn, Routes.group_path(conn, :index))

      assert %{
               "id" => ^id,
               "name" => "some name",
               "accounts" => [^account_user, ^account_admin]
             } = hd(json_response(conn, 200))
    end

    test "renders error when group name is invalid", %{conn: conn} do
      account_user = fixture(:user)
      account_admin = fixture(:admin)

      account_ids = [account_user.id, account_admin.id]

      conn =
        conn
        |> login(account_admin)
        |> post(
          Routes.group_path(conn, :create),
          %{group: @invalid_attrs}
          |> Map.put(:account_ids, account_ids)
        )

      assert json_response(conn, 400)
    end

    test "renders error when group name is `admin`", %{conn: conn} do
      account_user = fixture(:user)
      account_admin = fixture(:admin)

      account_ids = [account_user.id, account_admin.id]

      conn =
        conn
        |> login(account_admin)
        |> post(
          Routes.group_path(conn, :create),
          %{group: %{name: "admin"}}
          |> Map.put(:account_ids, account_ids)
        )

      assert json_response(conn, 400)["message"]["name"] == ["is reserved"]
    end

    test "renders error when group name is `blog-writer`", %{conn: conn} do
      account_user = fixture(:user)
      account_admin = fixture(:admin)

      account_ids = [account_user.id, account_admin.id]
      blog_group_name = Application.get_env(:rc, RC.Groups) |> Keyword.get(:blog_group_name)

      conn =
        conn
        |> login(account_admin)
        |> post(
          Routes.group_path(conn, :create),
          %{group: %{name: blog_group_name}}
          |> Map.put(:account_ids, account_ids)
        )

      assert json_response(conn, 400)["message"]["name"] == ["is reserved"]
    end

    test "renders error when user id is invalid", %{conn: conn} do
      account_user = fixture(:user)
      account_admin = fixture(:admin)

      account_ids = [account_user.id * 2, account_admin.id]

      conn =
        conn
        |> login(account_admin)
        |> post(
          Routes.group_path(conn, :create),
          %{group: @create_attrs}
          |> Map.put(:account_ids, account_ids)
        )

      assert json_response(conn, 400)["message"]["account_id"] == ["does not exist"]
    end

    test "renders error when all user ids are invalid", %{conn: conn} do
      account_user = fixture(:user)
      account_admin = fixture(:admin)

      account_ids = [account_user.id * 2, account_admin.id * 2]

      conn =
        conn
        |> login(account_admin)
        |> post(
          Routes.group_path(conn, :create),
          %{group: @create_attrs}
          |> Map.put(:account_ids, account_ids)
        )

      assert json_response(conn, 400)["message"]["account_id"] == ["does not exist"]
    end

    test "renders error when twice same user id", %{conn: conn} do
      account_user = fixture(:user)
      account_admin = fixture(:admin)

      account_ids = [account_user.id, account_user.id]

      conn =
        conn
        |> login(account_admin)
        |> post(
          Routes.group_path(conn, :create),
          %{group: @create_attrs}
          |> Map.put(:account_ids, account_ids)
        )

      assert json_response(conn, 409)["message"]["unique"] == ["has already been taken"]
    end
  end

  describe "add instance" do
    test "renders group when data is valid", %{conn: conn} do
      account_user = fixture(:user)
      account_admin = fixture(:admin)

      account_ids = [account_user.id, account_admin.id]

      conn =
        conn
        |> login(account_admin)
        |> post(
          Routes.group_path(conn, :create),
          %{group: @create_attrs}
          |> Map.put(:account_ids, account_ids)
        )

      assert %{"id" => id, "accounts" => [_account_admin_body, _account_user_body]} = json_response(conn, 201)

      %{instance: instance} = instance_fixture()

      conn =
        build_api_conn()
        |> login(account_admin)
        |> post(
          Routes.group_path(conn, :add_instances, id),
          %{instance_ids: [instance.id]}
        )

      conn = get(conn, Routes.group_path(conn, :index))

      assert %{
               "id" => ^id,
               "name" => "some name",
               "accounts" => [_account_user, _account_admin],
               "instances" => [_instance]
             } = hd(json_response(conn, 200))
    end

    test "renders error when group id is invalid", %{conn: conn} do
      account_user = fixture(:user)
      account_admin = fixture(:admin)

      account_ids = [account_user.id, account_admin.id]

      conn =
        conn
        |> login(account_admin)
        |> post(
          Routes.group_path(conn, :create),
          %{group: @create_attrs}
          |> Map.put(:account_ids, account_ids)
        )

      assert %{"id" => id, "accounts" => [_account_user_body, _account_admin_body]} = json_response(conn, 201)

      %{instance: instance} = instance_fixture()

      conn =
        build_api_conn()
        |> login(account_admin)
        |> post(
          Routes.group_path(conn, :add_instances, id * 2),
          %{instance_ids: [instance.id]}
        )

      assert json_response(conn, 404)["message"] == "group_not_found"
    end

    test "renders error when instance id is invalid", %{conn: conn} do
      account_user = fixture(:user)
      account_admin = fixture(:admin)

      account_ids = [account_user.id, account_admin.id]

      conn =
        conn
        |> login(account_admin)
        |> post(
          Routes.group_path(conn, :create),
          %{group: @create_attrs}
          |> Map.put(:account_ids, account_ids)
        )

      assert %{"id" => id, "accounts" => [_account_user_body, _account_admin_body]} = json_response(conn, 201)

      %{instance: instance} = instance_fixture()

      conn =
        build_api_conn()
        |> login(account_admin)
        |> post(
          Routes.group_path(conn, :add_instances, id),
          %{instance_ids: [instance.id * 2]}
        )

      assert json_response(conn, 400)["message"]["instance_id"] == ["does not exist"]
    end

    test "renders error when twice the same instance id", %{conn: conn} do
      account_user = fixture(:user)
      account_admin = fixture(:admin)

      account_ids = [account_user.id, account_admin.id]

      conn =
        conn
        |> login(account_admin)
        |> post(
          Routes.group_path(conn, :create),
          %{group: @create_attrs}
          |> Map.put(:account_ids, account_ids)
        )

      assert %{"id" => id, "accounts" => [_account_user_body, _account_admin_body]} = json_response(conn, 201)

      %{instance: instance} = instance_fixture()

      conn =
        build_api_conn()
        |> login(account_admin)
        |> post(
          Routes.group_path(conn, :add_instances, id),
          %{instance_ids: [instance.id, instance.id]}
        )

      assert json_response(conn, 409)["message"]["unique"] == ["has already been taken"]
    end
  end

  describe "add account" do
    test "renders group when data is valid", %{conn: conn} do
      account_user = fixture(:user)
      account_admin = fixture(:admin)

      account_ids = [account_user.id]

      conn =
        conn
        |> login(account_admin)
        |> post(
          Routes.group_path(conn, :create),
          %{group: @create_attrs}
          |> Map.put(:account_ids, account_ids)
        )

      assert %{"id" => id, "accounts" => [_account_user_body]} = json_response(conn, 201)

      conn =
        build_api_conn()
        |> login(account_admin)
        |> post(
          Routes.group_path(conn, :add_accounts, id),
          %{account_ids: [account_admin.id]}
        )

      conn = get(conn, Routes.group_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "name" => "some name",
               "accounts" => [_account_admin, _account_user]
             } = json_response(conn, 200)
    end
  end

  describe "delete group" do
    test "deletes specific group", %{conn: conn} do
      account_user = fixture(:user)
      account_admin = fixture(:admin)

      account_ids = [account_user.id, account_admin.id]

      conn =
        conn
        |> login(account_admin)
        |> post(
          Routes.group_path(conn, :create),
          %{group: @create_attrs}
          |> Map.put(:account_ids, account_ids)
        )

      assert %{"id" => id, "accounts" => [_account_user_body, _account_admin_body]} = json_response(conn, 201)

      conn =
        build_api_conn()
        |> login(account_admin)
        |> delete(Routes.group_path(conn, :delete, id))

      assert response(conn, 204)

      assert RC.Repo.aggregate(Group, :count, :id) == 0
    end
  end

  describe "remove account" do
    test "deletes specific account", %{conn: conn} do
      account_user = fixture(:user)
      account_admin = fixture(:admin)

      account_ids = [account_user.id, account_admin.id]

      conn =
        conn
        |> login(account_admin)
        |> post(
          Routes.group_path(conn, :create),
          %{group: @create_attrs}
          |> Map.put(:account_ids, account_ids)
        )

      assert %{"id" => id, "accounts" => [_account_user_body, _account_admin_body]} = json_response(conn, 201)

      conn =
        build_api_conn()
        |> login(account_admin)
        |> delete(Routes.group_path(conn, :remove_account, id, account_user.id))

      assert response(conn, 204)

      conn = get(conn, Routes.group_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "name" => "some name",
               "accounts" => [_account_admin]
             } = json_response(conn, 200)
    end
  end

  describe "remove instance" do
    test "deletes specific instance", %{conn: conn} do
      account_user = fixture(:user)
      account_admin = fixture(:admin)

      account_ids = [account_user.id, account_admin.id]

      conn =
        conn
        |> login(account_admin)
        |> post(
          Routes.group_path(conn, :create),
          %{group: @create_attrs}
          |> Map.put(:account_ids, account_ids)
        )

      assert %{"id" => id, "accounts" => [_account_user_body, _account_admin_body]} = json_response(conn, 201)

      %{instance: instance} = instance_fixture()

      conn =
        build_api_conn()
        |> login(account_admin)
        |> post(
          Routes.group_path(conn, :add_instances, id),
          %{instance_ids: [instance.id]}
        )

      assert json_response(conn, 201)

      conn =
        build_api_conn()
        |> login(account_admin)
        |> delete(Routes.group_path(conn, :remove_instance, id, instance.id))

      assert response(conn, 204)

      conn = get(conn, Routes.group_path(conn, :index))

      assert %{
               "id" => ^id,
               "name" => "some name",
               "accounts" => [_account_user, _account_admin],
               "instances" => []
             } = hd(json_response(conn, 200))
    end
  end

  describe "access instance" do
    test "returns instance when user in group", %{conn: conn} do
      account_user = fixture(:user)
      account_admin = fixture(:admin)

      account_ids = [account_user.id, account_admin.id]

      conn =
        conn
        |> login(account_admin)
        |> post(
          Routes.group_path(conn, :create),
          %{group: @create_attrs}
          |> Map.put(:account_ids, account_ids)
        )

      assert %{"id" => id, "accounts" => [_account_user_body, _account_admin_body]} = json_response(conn, 201)

      %{instance: instance} = instance_fixture()

      conn =
        build_api_conn()
        |> login(account_admin)
        |> post(
          Routes.group_path(conn, :add_instances, id),
          %{instance_ids: [instance.id]}
        )

      conn =
        build_api_conn()
        |> login(account_user)
        |> get(Routes.instance_path(conn, :show, instance.id))

      assert json_response(conn, 200)
    end

    test "returns forbidden when user not in group", %{conn: conn} do
      account_user = fixture(:user)
      account_admin = fixture(:admin)

      account_ids = [account_admin.id]

      conn =
        conn
        |> login(account_admin)
        |> post(
          Routes.group_path(conn, :create),
          %{group: @create_attrs}
          |> Map.put(:account_ids, account_ids)
        )

      assert %{"id" => id, "accounts" => [_account_admin_body]} = json_response(conn, 201)

      %{instance: instance} = instance_fixture()

      conn =
        build_api_conn()
        |> login(account_admin)
        |> post(
          Routes.group_path(conn, :add_instances, id),
          %{instance_ids: [instance.id]}
        )

      conn =
        build_api_conn()
        |> login(account_user)
        |> get(Routes.instance_path(conn, :show, instance.id))

      assert json_response(conn, 403)["message"] == "forbidden"
    end
  end

  describe "update group" do
    test "returns updated group", %{conn: conn} do
      account_user = fixture(:user)
      account_admin = fixture(:admin)

      account_ids = [account_user.id, account_admin.id]

      conn =
        conn
        |> login(account_admin)
        |> post(
          Routes.group_path(conn, :create),
          %{group: @create_attrs}
          |> Map.put(:account_ids, account_ids)
        )

      assert %{"id" => id, "accounts" => [_account_user_body, _account_admin_body]} = json_response(conn, 201)

      conn =
        build_api_conn()
        |> login(account_admin)
        |> put(Routes.group_path(conn, :update, id), %{group: %{name: "some updated name"}})

      assert json_response(conn, 200)["name"] == "some updated name"
    end
  end
end
