defmodule Portal.ScenarioControllerTest do
  use Portal.APIConnCase

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

  @invalid_attrs %{game_data: nil, is_official: nil}

  @scenario_create_attrs_thumbnail %{
    game_data: %{"data" => "some data"},
    game_metadata: %{},
    thumbnail: @image_plug_upload,
    is_official: true
  }

  @scenario_create_attrs_filters %{
    game_data: %{speed: "fast", victory_type: "kaboom"},
    game_metadata: %{speed: "fast", victory_type: "kaboom", size: 500},
    thumbnail: @image_plug_upload
  }

  @scenario_update_attrs_thumbnail %{
    game_data: %{"data" => "some updated data"},
    is_official: false
  }

  @scenario_create_attrs %{
    game_data: %{"data" => "some data"},
    game_metadata: %{},
    is_official: true
  }

  @scenario_invalid_attrs %{
    game_data: nil,
    game_metadata: %{},
    thumbnail: nil
  }

  setup %{conn: conn} do
    on_exit(fn -> File.rm_rf(@stored_file_path) end)
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  defp get_path(id, filename) do
    Path.join([@stored_file_path, "#{id}", filename])
  end

  describe "index" do
    setup [:create_account_user]

    test "lists all scenarios", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> get(Routes.scenario_path(conn, :index))

      assert json_response(conn, 200) == []
      assert conn.assigns.scenarios.total_entries == 0
    end
  end

  describe "index with filters" do
    setup [:create_account_admin]

    test "lists filtered scenarios", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> post(Routes.scenario_path(conn, :create), scenario: @scenario_create_attrs_filters)

      assert response(conn, 201)

      {:ok, account: account_user} = create_account_user(%{})

      conn =
        build_conn()
        |> login(account_user)
        |> get(Routes.scenario_path(conn, :index, %{size: 500}))

      assert [map] = json_response(conn, 200)
      assert map["game_metadata"]["size"] == 500
      assert map["game_metadata"]["speed"] == "fast"
    end

    test "lists filtered scenarios returns empty list if wrong filter", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> post(Routes.scenario_path(conn, :create), scenario: @scenario_create_attrs_filters)

      assert response(conn, 201)

      {:ok, account: account_user} = create_account_user(%{})

      conn =
        build_conn()
        |> login(account_user)
        |> get(Routes.scenario_path(conn, :index, %{size: 600}))

      assert [] = json_response(conn, 200)
    end
  end

  describe "create scenario" do
    setup [:create_account_admin]

    test "renders scenario when data with thumbnail is valid", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> post(Routes.scenario_path(conn, :create), scenario: @scenario_create_attrs_thumbnail)

      assert %{"id" => id} = json_response(conn, 201)

      conn =
        build_conn()
        |> login(account)
        |> get(Routes.scenario_path(conn, :show, id))

      assert %{
               "id" => id,
               "game_data" => %{"data" => "some data"},
               "is_official" => true,
               "likes" => 0,
               "dislikes" => 0,
               "favorites" => 0
             } = json_response(conn, 200)

      assert File.exists?(get_path(id, "test_thumb.png")) == true
    end

    test "renders scenario when data without thumbnail is valid and map has thumbnail", %{
      conn: conn,
      account: account
    } do
      conn =
        conn
        |> login(account)
        |> post(Routes.scenario_path(conn, :create), scenario: @scenario_create_attrs)

      assert %{"id" => id} = json_response(conn, 201)

      conn =
        build_conn()
        |> login(account)
        |> get(Routes.scenario_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "game_data" => %{"data" => "some data"},
               "is_official" => true,
               "likes" => 0,
               "dislikes" => 0,
               "favorites" => 0
             } = json_response(conn, 200)
    end

    test "renders scenario when data without thumbnail is valid and map has no thumbnail", %{
      conn: conn,
      account: account
    } do
      conn =
        conn
        |> login(account)
        |> post(Routes.scenario_path(conn, :create), scenario: @scenario_create_attrs)

      assert %{"id" => id} = json_response(conn, 201)

      conn =
        build_conn()
        |> login(account)
        |> get(Routes.scenario_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "game_data" => %{"data" => "some data"},
               "is_official" => true,
               "likes" => 0,
               "dislikes" => 0,
               "favorites" => 0,
               "thumbnail" => nil
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      account: account
    } do
      conn =
        conn
        |> login(account)
        |> post(Routes.scenario_path(conn, :create), scenario: @scenario_invalid_attrs)

      assert json_response(conn, 400) == %{
               "message" => %{"game_data" => ["can't be blank"]}
             }
    end
  end

  describe "update scenario" do
    setup [:create_account_admin]

    test "renders scenario when data is valid", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> post(Routes.scenario_path(conn, :create), scenario: @scenario_create_attrs_thumbnail)

      assert %{"id" => id} = json_response(conn, 201)

      conn =
        build_conn()
        |> login(account)
        |> put(Routes.scenario_path(conn, :update, id), scenario: @scenario_update_attrs_thumbnail)

      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, Routes.scenario_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "game_data" => %{"data" => "some updated data"},
               "is_official" => false,
               "likes" => 0,
               "dislikes" => 0,
               "favorites" => 0
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> post(Routes.scenario_path(conn, :create), scenario: @scenario_create_attrs_thumbnail)

      assert %{"id" => id} = json_response(conn, 201)

      conn =
        build_conn()
        |> login(account)
        |> put(Routes.scenario_path(conn, :update, id), scenario: @invalid_attrs)

      assert json_response(conn, 400) == %{
               "message" => %{"game_data" => ["can't be blank"], "is_official" => ["can't be blank"]}
             }
    end
  end

  describe "delete scenario" do
    setup [:create_account_admin]

    test "deletes chosen scenario", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> post(Routes.scenario_path(conn, :create), scenario: @scenario_create_attrs_thumbnail)

      assert %{"id" => id} = json_response(conn, 201)

      conn =
        build_conn()
        |> login(account)
        |> delete(Routes.scenario_path(conn, :delete, id))

      assert response(conn, 204)

      conn =
        build_conn()
        |> login(account)
        |> get(Routes.scenario_path(conn, :show, id))

      assert json_response(conn, 404)["message"] == "not_found"
    end
  end
end
