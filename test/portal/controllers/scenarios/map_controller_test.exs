defmodule Portal.MapControllerTest do
  use Portal.APIConnCase

  alias RC.Scenarios

  import RC.Fixtures

  @filename "test.png"
  @file_path Path.join([File.cwd!(), "/test/support/", @filename])

  @stored_file_path Path.join([
                      File.cwd!(),
                      Application.compile_env(:waffle, :storage_dir),
                      Application.compile_env(:rc, RC.Uploader.ThumbnailFile) |> Keyword.get(:path),
                      "scenarios"
                    ])

  @image_plug_upload %Plug.Upload{
    content_type: "image/png",
    filename: @filename,
    path: @file_path
  }

  @create_attrs %{
    game_data: %{map: %{size: 100}},
    game_metadata: %{map: %{size: 100}},
    is_map: true,
    is_official: true,
    thumbnail: @image_plug_upload
  }
  @update_attrs %{
    game_data: %{update: "update content"},
    game_metadata: %{},
    is_map: true,
    is_official: false,
    thumbnail: @image_plug_upload
  }
  @invalid_attrs %{game_data: nil, is_official: nil}

  def fixture_map() do
    {:ok, %{map_with_thumbnail: map}} = Scenarios.create_map(@create_attrs)
    map
  end

  setup %{conn: conn} do
    on_exit(fn -> File.rm_rf(@stored_file_path) end)
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_account_user]

    test "lists all maps", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> get(Routes.map_path(conn, :index))

      assert json_response(conn, 200) == []
      assert conn.assigns.maps.total_entries == 0
    end

    test "with filters lists filtered maps", %{conn: conn, account: account} do
      _map = fixture_map()

      conn =
        conn
        |> login(account)
        |> get(Routes.map_path(conn, :index, %{speed: 100}))

      assert [map_returned] = json_response(conn, 200)
      assert map_returned["game_metadata"]["map"]["size"] == 100
      assert conn.assigns.maps.total_entries == 1
    end

    test "with wrong filters returns empty list", %{conn: conn, account: account} do
      _map = fixture_map()

      conn =
        conn
        |> login(account)
        |> get(Routes.map_path(conn, :index, %{size: 1000}))

      assert json_response(conn, 200) == []
      assert conn.assigns.maps.total_entries == 0
    end
  end

  describe "create map" do
    setup [:create_account_admin]

    test "renders map when data is valid", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> post(Routes.map_path(conn, :create), map: @create_attrs)

      assert %{"id" => id} = json_response(conn, 201)

      conn =
        build_conn()
        |> login(account)
        |> get(Routes.map_path(conn, :show, id))

      assert %{
               "id" => id,
               "game_data" => %{},
               "is_official" => true,
               "likes" => 0,
               "dislikes" => 0,
               "favorites" => 0
             } = json_response(conn, 200)

      assert File.exists?(Path.join([@stored_file_path, "#{id}", "test_thumb.png"])) == true
    end

    test "renders map when data without thumbnail is valid", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> post(Routes.map_path(conn, :create), map: Map.delete(@create_attrs, :thumbnail))

      assert %{"id" => id} = json_response(conn, 201)

      conn =
        build_conn()
        |> login(account)
        |> get(Routes.map_path(conn, :show, id))

      assert %{
               "id" => _id,
               "game_data" => %{},
               "is_official" => true,
               "likes" => 0,
               "dislikes" => 0,
               "favorites" => 0
             } = json_response(conn, 200)

      assert File.exists?(@stored_file_path <> "test_thumb.png") == false
    end

    test "renders errors when data is invalid", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> post(Routes.map_path(conn, :create), map: @invalid_attrs)

      assert json_response(conn, 400)["message"] == %{
               "game_data" => ["can't be blank"],
               "game_metadata" => ["can't be blank"],
               "is_map" => ["can't be blank"],
               "is_official" => ["can't be blank"]
             }

      assert File.exists?(Path.join([@stored_file_path, "test_thumb.png"])) == false
    end
  end

  describe "update map" do
    setup [:create_map, :create_account_admin]

    test "renders map when data is valid", %{conn: conn, map: %RC.Scenarios.Map{id: id} = map, account: account} do
      conn =
        conn
        |> login(account)
        |> put(Routes.map_path(conn, :update, map), map: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, Routes.map_path(conn, :show, id))

      assert %{
               "id" => _id,
               "game_data" => %{"update" => "update content"},
               "is_official" => false,
               "likes" => 0,
               "dislikes" => 0,
               "favorites" => 0
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, map: map, account: account} do
      conn =
        conn
        |> login(account)
        |> put(Routes.map_path(conn, :update, map), map: @invalid_attrs)

      assert json_response(conn, 400) == %{
               "message" => %{"game_data" => ["can't be blank"], "is_official" => ["can't be blank"]}
             }
    end
  end

  describe "delete map" do
    setup [:create_map, :create_account_admin]

    test "deletes chosen map", %{conn: conn, map: map, account: account} do
      conn =
        conn
        |> login(account)
        |> delete(Routes.map_path(conn, :delete, map))

      assert response(conn, 204)

      conn =
        build_conn()
        |> login(account)
        |> get(Routes.map_path(conn, :show, map))

      assert json_response(conn, 404)["message"] == "not_found"
    end
  end

  defp create_map(_) do
    map = fixture_map()
    {:ok, map: map}
  end
end
