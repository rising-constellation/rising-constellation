defmodule Portal.FolderControllerTest do
  use Portal.APIConnCase

  alias RC.Scenarios
  alias RC.Scenarios.Folder

  import RC.Fixtures

  @filename "test.png"
  @file_path File.cwd!() <> "/test/support/" <> @filename

  @stored_file_path File.cwd!() <>
                      "/" <>
                      Application.compile_env(:waffle, :storage_dir) <>
                      "/"

  @image_plug_upload %Plug.Upload{
    content_type: "image/png",
    filename: @filename,
    path: @file_path
  }

  @map_create_attrs %{
    game_data: %{},
    game_metadata: %{},
    is_map: true,
    is_official: true,
    thumbnail: @image_plug_upload
  }

  @scenario_create_attrs %{
    game_data: %{"data" => "some data"},
    game_metadata: %{}
  }

  @folder_create_attrs %{
    name: "some name",
    description: "some description"
  }

  @folder_update_attrs %{
    name: "some updated name",
    description: "some updated description"
  }

  @folder_invalid_attrs %{
    name: nil,
    description: nil
  }

  def map_fixture(attrs \\ %{}) do
    {:ok, %{map_with_thumbnail: map}} =
      attrs
      |> Enum.into(@map_create_attrs)
      |> Scenarios.create_map()

    map
  end

  def scenario_fixture(attrs \\ %{}) do
    {:ok, %{map_with_thumbnail: map}} =
      attrs
      |> Enum.into(@map_create_attrs)
      |> Scenarios.create_map()

    {:ok, scenario} =
      Scenarios.create_scenario(
        %{
          game_data: Map.merge(map.game_data, @scenario_create_attrs.game_data),
          game_metadata: Map.merge(map.game_data, @scenario_create_attrs.game_metadata),
          is_official: map.is_official,
          is_map: false,
          thumbnail: map.thumbnail
        },
        :reuse_thumbnail
      )

    scenario
  end

  setup %{conn: conn} do
    on_exit(fn -> File.rm_rf(@stored_file_path) end)
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_account_user]

    test "lists all folders", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> get(Routes.folder_path(conn, :index))

      assert json_response(conn, 200) == []
      assert conn.assigns.folders.total_entries == 0
    end
  end

  describe "create folder" do
    setup [:create_account_admin]

    test "renders data when data is valid", %{conn: conn, account: account} do
      scenario = scenario_fixture()

      conn =
        conn
        |> login(account)
        |> post(Routes.folder_path(conn, :create), %{folder: @folder_create_attrs, scenario_or_map_ids: [scenario.id]})

      assert %{"id" => id} = json_response(conn, 201)

      conn =
        build_conn()
        |> login(account)
        |> get(Routes.folder_path(conn, :show, id))

      aid = account.id

      assert %{
               "id" => ^id,
               "name" => "some name",
               "account_id" => ^aid
             } = json_response(conn, 200)
    end

    test "renders data when multiple insert", %{conn: conn, account: account} do
      scenario = scenario_fixture()
      map = map_fixture()

      conn =
        conn
        |> login(account)
        |> post(Routes.folder_path(conn, :create), %{
          folder: @folder_create_attrs,
          scenario_or_map_ids: [scenario.id, map.id]
        })

      assert %{"id" => id} = json_response(conn, 201)

      conn =
        build_conn()
        |> login(account)
        |> get(Routes.folder_path(conn, :show, id))

      aid = account.id

      assert %{
               "id" => ^id,
               "name" => "some name",
               "account_id" => ^aid
             } = json_response(conn, 200)

      assert RC.Repo.aggregate(RC.Scenarios.ScenarioFolder, :count) == 2
    end

    test "renders error when one id is invalid", %{conn: conn, account: account} do
      scenario = scenario_fixture()
      map = map_fixture()

      conn =
        conn
        |> login(account)
        |> post(Routes.folder_path(conn, :create), %{
          folder: @folder_create_attrs,
          scenario_or_map_ids: [scenario.id, map.id * 2]
        })

      assert json_response(conn, 400)["message"] == %{"scenario_id" => ["does not exist"]}
    end

    test "renders created when scenario ids are empty", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> post(Routes.folder_path(conn, :create), %{folder: @folder_create_attrs, scenario_or_map_ids: []})

      assert %{"id" => id} = json_response(conn, 201)

      conn =
        build_conn()
        |> login(account)
        |> get(Routes.folder_path(conn, :show, id))

      aid = account.id

      assert %{
               "id" => ^id,
               "name" => "some name",
               "account_id" => ^aid
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, account: account} do
      scenario = scenario_fixture()

      conn =
        conn
        |> login(account)
        |> post(Routes.folder_path(conn, :create), folder: @folder_invalid_attrs, scenario_or_map_ids: [scenario.id])

      assert json_response(conn, 400)
    end

    test "renders error when using a reserved name", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> post(Routes.folder_path(conn, :create), %{
          folder:
            @folder_create_attrs
            |> Map.put(:name, Application.get_env(:rc, RC.Scenarios.Folder) |> Keyword.get(:scenario_likes_name)),
          scenario_or_map_ids: []
        })

      assert json_response(conn, 400)["message"]["name"] == ["is reserved"]
    end
  end

  describe "update folder" do
    setup [:create_account_admin]

    test "renders folder when data is valid", %{conn: conn, account: account} do
      scenario = scenario_fixture()

      conn =
        conn
        |> login(account)
        |> post(Routes.folder_path(conn, :create), %{folder: @folder_create_attrs, scenario_or_map_ids: [scenario.id]})

      assert %{"id" => id} = json_response(conn, 201)

      conn =
        build_conn()
        |> login(account)
        |> put(Routes.folder_path(conn, :update, id), folder: @folder_update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, Routes.folder_path(conn, :show, id))

      assert %{
               "id" => _id,
               "name" => "some updated name"
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, account: account} do
      scenario = scenario_fixture()

      conn =
        conn
        |> login(account)
        |> post(Routes.folder_path(conn, :create), %{folder: @folder_create_attrs, scenario_or_map_ids: [scenario.id]})

      assert %{"id" => id} = json_response(conn, 201)

      conn =
        build_conn()
        |> login(account)
        |> put(Routes.folder_path(conn, :update, id), folder: @folder_invalid_attrs)

      assert json_response(conn, 400)["errors"] != %{}
    end
  end

  describe "delete folder" do
    setup [:create_account_admin]

    test "deletes chosen folder", %{conn: conn, account: account} do
      scenario = scenario_fixture()

      conn =
        conn
        |> login(account)
        |> post(Routes.folder_path(conn, :create), %{folder: @folder_create_attrs, scenario_or_map_ids: [scenario.id]})

      assert %{"id" => id} = json_response(conn, 201)

      conn =
        build_conn()
        |> login(account)
        |> delete(Routes.folder_path(conn, :delete, id))

      assert response(conn, 204)

      assert RC.Repo.all(Folder) == []
    end
  end

  describe "insert" do
    setup [:create_account_admin]

    test "inserts a given scenario into a folder", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> post(Routes.folder_path(conn, :create), %{folder: @folder_create_attrs, scenario_or_map_ids: []})

      assert %{"id" => id} = json_response(conn, 201)

      scenario = scenario_fixture()

      conn =
        build_conn()
        |> login(account)
        |> put(Routes.folder_path(conn, :insert, scenario.id, id))

      [sf] = RC.Repo.all(RC.Scenarios.ScenarioFolder)

      assert json_response(conn, 200)["message"] == "scenario_inserted"
      assert sf.scenario_id == scenario.id
      assert sf.folder_id == id
    end
  end

  describe "remove" do
    setup [:create_account_admin]

    test "remove a given scenario from a folder", %{conn: conn, account: account} do
      scenario = scenario_fixture()

      conn =
        conn
        |> login(account)
        |> post(Routes.folder_path(conn, :create), %{folder: @folder_create_attrs, scenario_or_map_ids: [scenario.id]})

      assert %{"id" => id} = json_response(conn, 201)

      conn =
        build_conn()
        |> login(account)
        |> delete(Routes.folder_path(conn, :remove, scenario.id, id))

      assert response(conn, 204)
      assert RC.Repo.all(RC.Scenarios.ScenarioFolder) == []
    end

    test "returns error if scenario does not exist", %{conn: conn, account: account} do
      scenario = scenario_fixture()

      conn =
        conn
        |> login(account)
        |> post(Routes.folder_path(conn, :create), %{folder: @folder_create_attrs, scenario_or_map_ids: [scenario.id]})

      assert %{"id" => id} = json_response(conn, 201)

      conn =
        build_conn()
        |> login(account)
        |> delete(Routes.folder_path(conn, :remove, scenario.id * 2, id))

      assert json_response(conn, 404)["message"] == "scenario_not_found"
      assert RC.Repo.aggregate(RC.Scenarios.ScenarioFolder, :count) == 1
    end
  end

  # identical code for the 3 specials folders
  describe "like/dislike/favorite" do
    setup [:create_account_admin]

    test "add a scenario into a reserved folder", %{conn: conn, account: account} do
      scenario = scenario_fixture()

      conn =
        conn
        |> login(account)
        |> post(Routes.folder_path(conn, :like, scenario.id))

      [f] = RC.Repo.all(RC.Scenarios.Folder)

      assert json_response(conn, 200)["message"] == "liked"
      assert f.name == "scenario-likes"
      assert f.account_id == account.id
    end

    test "add a map into a reserved folder", %{conn: conn, account: account} do
      map = map_fixture()

      conn =
        conn
        |> login(account)
        |> post(Routes.folder_path(conn, :like, map.id))

      [f] = RC.Repo.all(RC.Scenarios.Folder)

      assert json_response(conn, 200)["message"] == "liked"
      assert f.name == "scenario-likes"
      assert f.account_id == account.id
    end

    test "removes the scenario from the like folder when dislike", %{conn: conn, account: account} do
      scenario = scenario_fixture()

      conn =
        conn
        |> login(account)
        |> post(Routes.folder_path(conn, :like, scenario.id))

      conn =
        build_conn()
        |> login(account)
        |> post(Routes.folder_path(conn, :dislike, scenario.id))

      assert json_response(conn, 200)["message"] == "disliked"
      assert RC.Repo.aggregate(RC.Scenarios.Folder, :count) == 2
      assert RC.Repo.aggregate(RC.Scenarios.ScenarioFolder, :count) == 1
    end
  end
end
