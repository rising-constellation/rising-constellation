defmodule Portal.ProfileControllerTest do
  use Portal.APIConnCase
  import RC.Fixtures
  import RC.ScenarioFixtures

  alias RC.Accounts.Profile

  alias RC.Repo

  @stored_file_path File.cwd!() <>
                      "/" <>
                      Application.getcompile_env_env(:waffle, :storage_dir) <>
                      "/"

  @profile_valid_attrs %{
    "avatar" => "some avatar",
    "name" => "some name",
    "full_name" => "some full_name",
    "description" => "some description",
    "long_description" => "some long_description",
    "age" => 30
  }

  @profile_update_attrs %{
    "avatar" => "some updated avatar",
    "name" => "some updated name",
    "full_name" => "some updated full_name",
    "description" => "some updated description",
    "long_description" => "some updated long_description",
    "age" => 50
  }

  def instance_and_account_fixture(_) do
    %{instance: instance} = instance_fixture()
    {:ok, account: account} = create_account_user(%{})

    Machinery.transition_to(instance |> Map.put(:account_id, account.id), RC.Instances.InstanceStateMachine, "open")

    profile_params = %{avatar: "TODO", name: account.name, account_id: account.id}

    {:ok, profile} = Repo.insert(Profile.changeset(%Profile{}, profile_params))

    profile_params2 = %{avatar: "TODO", name: "another profile name", account_id: account.id}

    {:ok, profile2} = Repo.insert(Profile.changeset(%Profile{}, profile_params2))

    [faction | [faction2]] = instance.factions

    {:ok,
     %{instance: instance, account: account, profile: profile, profile2: profile2, faction: faction, faction2: faction2}}
  end

  setup %{conn: conn} do
    on_exit(fn -> File.rm_rf(@stored_file_path) end)
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_account_admin]

    test "list profiles list all profiles", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> get(Routes.profile_path(conn, :index_by_account, account.id))

      assert json_response(conn, 200) == []
    end
  end

  describe "index with valid registrations" do
    setup [:instance_and_account_fixture]

    test "list profiles with last registrations", %{
      conn: conn,
      instance: instance,
      account: account,
      profile: profile,
      profile2: profile2,
      faction: faction
    } do
      {:ok, %{registration: registration}} = RC.Registrations.register_profile(faction, profile)

      {:ok, %{registration: registration2}} = RC.Registrations.register_profile(faction, profile2)

      # profile 1 is "killed", profile 2 is "dead"
      {:ok, registration} = RC.Registrations.transition_to(registration, "playing")

      {:ok, registration2} = RC.Registrations.transition_to(registration2, "playing")
      # {:ok, registration2} = RC.Registrations.transition_to(registration2, "dead")

      conn =
        conn
        |> login(account)
        |> get(Routes.profile_path(conn, :index_by_account, account.id))

      [p1, p2] = json_response(conn, 200) |> Enum.sort_by(& &1["id"])
      assert length(p1["registrations"]) == 1
      assert p1["registrations"] |> hd() |> Map.get("state") == registration.state
      assert length(p2["registrations"]) == 1
      assert p2["registrations"] |> hd() |> Map.get("state") == registration2.state
      assert hd(p1["registrations"])["faction"]["id"] == faction.id
      assert hd(p1["registrations"])["faction"]["instance"]["id"] == instance.id
      assert hd(p2["registrations"])["faction"]["id"] == faction.id
      assert hd(p2["registrations"])["faction"]["instance"]["id"] == instance.id
    end

    test "list profiles with last registrations and not inactive registrations", %{
      conn: conn,
      instance: _instance,
      account: account,
      profile: profile,
      profile2: profile2,
      faction: faction
    } do
      {:ok, %{registration: registration}} = RC.Registrations.register_profile(faction, profile)

      {:ok, %{registration: registration2}} = RC.Registrations.register_profile(faction, profile2)

      # profile 1 is "killed", profile 2 is "dead"
      {:ok, registration} = RC.Registrations.transition_to(registration, "playing")

      {:ok, registration2} = RC.Registrations.transition_to(registration2, "playing")
      {:ok, _registration2} = RC.Registrations.transition_to(registration2, "dead")

      conn =
        conn
        |> login(account)
        |> get(Routes.profile_path(conn, :index_by_account, account.id))

      [p1, p2] = json_response(conn, 200) |> Enum.sort_by(& &1["id"])
      assert length(p1["registrations"]) == 1
      assert p1["registrations"] |> hd() |> Map.get("state") == registration.state
      assert Enum.empty?(p2["registrations"])
    end
  end

  describe "create" do
    setup [:create_account_user]

    test "creates a new profile", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> post(Routes.profile_path(conn, :create, account.id), %{profile: @profile_valid_attrs})

      assert json_response(conn, 201) |> Map.delete("id") == @profile_valid_attrs
    end

    test "returns error if limit is reached", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> post(Routes.profile_path(conn, :create, account.id), %{profile: @profile_valid_attrs})

      conn =
        build_conn()
        |> login(account)
        |> post(Routes.profile_path(conn, :create, account.id), %{
          profile: @profile_valid_attrs |> Map.put("name", "some other name")
        })

      conn =
        build_conn()
        |> login(account)
        |> post(Routes.profile_path(conn, :create, account.id), %{
          profile: @profile_valid_attrs |> Map.put("name", "some another name")
        })

      assert json_response(conn, 403)["message"] == "maximum_number_of_profiles_reached"
    end

    test "returns error if profile name is already taken", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> post(Routes.profile_path(conn, :create, account.id), %{profile: @profile_valid_attrs})

      conn =
        build_conn()
        |> login(account)
        |> post(Routes.profile_path(conn, :create, account.id), %{profile: @profile_valid_attrs})

      assert json_response(conn, 400)["message"]["name"] == ["has already been taken"]
    end

    test "returns error if profile if name is too long", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> post(Routes.profile_path(conn, :create, account.id), %{
          profile: @profile_valid_attrs |> Map.put("name", "a way too long name for a profile")
        })

      assert json_response(conn, 400)["message"]["name"] == ["should be at most 30 character(s)"]
    end
  end

  describe "update" do
    setup [:create_account_user]

    test "updates a profile", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> post(Routes.profile_path(conn, :create, account.id), %{profile: @profile_valid_attrs})

      assert %{"id" => id} = json_response(conn, 201)

      conn =
        build_conn()
        |> login(account)
        |> put(Routes.profile_path(conn, :update, id), %{profile: @profile_update_attrs})

      assert json_response(conn, 200) |> Map.delete("id") == @profile_update_attrs
    end

    test "returns error if profile does not exist", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> post(Routes.profile_path(conn, :create, account.id), %{profile: @profile_valid_attrs})

      assert %{"id" => id} = json_response(conn, 201)

      conn =
        build_conn()
        |> login(account)
        |> put(Routes.profile_path(conn, :update, id * 2), %{profile: @profile_update_attrs})

      assert response(conn, 403) == "forbidden"
    end
  end

  describe "show" do
    setup [:create_account_admin]

    test "show a profile", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> post(Routes.profile_path(conn, :create, account.id), %{profile: @profile_valid_attrs})

      assert %{"id" => id} = json_response(conn, 201)

      {:ok, account: account_user} = create_account_user(%{})

      conn =
        build_conn()
        |> login(account_user)
        |> get(Routes.profile_path(conn, :show, id))

      assert json_response(conn, 200) |> Map.delete("id") == @profile_valid_attrs
    end
  end
end
