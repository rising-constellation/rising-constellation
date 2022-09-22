defmodule Portal.RegistrationControllerTest do
  use Portal.APIConnCase
  import RC.Fixtures
  import RC.ScenarioFixtures

  alias RC.Accounts.Profile

  alias RC.Repo

  @stored_file_path File.cwd!() <>
                      "/" <>
                      Application.compile_env(:waffle, :storage_dir) <>
                      "/"

  setup do
    on_exit(fn -> File.rm_rf(@stored_file_path) end)
  end

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

  describe "register" do
    setup [:instance_and_account_fixture]

    test "registers a profile into an instance", %{
      conn: conn,
      instance: instance,
      account: account,
      profile: profile,
      faction: faction
    } do
      conn =
        conn
        |> login(account)
        |> post(Routes.registration_path(conn, :join, profile.id), %{instance_id: instance.id, faction_id: faction.id})

      assert json_response(conn, 200)["message"] == "registered"
    end

    test "returns error if already registered", %{
      conn: conn,
      instance: instance,
      account: account,
      profile: profile,
      faction: faction
    } do
      conn =
        conn
        |> login(account)
        |> post(Routes.registration_path(conn, :join, profile.id), %{instance_id: instance.id, faction_id: faction.id})

      conn =
        build_conn()
        |> login(account)
        |> post(Routes.registration_path(conn, :join, profile.id), %{instance_id: instance.id, faction_id: faction.id})

      assert json_response(conn, :conflict)["message"] == "already_registered"
    end

    test "returns error if already registered in another faction", %{
      conn: conn,
      instance: instance,
      account: account,
      profile: profile,
      faction: faction,
      faction2: faction2
    } do
      conn =
        conn
        |> login(account)
        |> post(Routes.registration_path(conn, :join, profile.id), %{instance_id: instance.id, faction_id: faction.id})

      conn =
        build_conn()
        |> login(account)
        |> post(Routes.registration_path(conn, :join, profile.id), %{instance_id: instance.id, faction_id: faction2.id})

      assert json_response(conn, :conflict)["message"] == "already_registered"
    end

    test "returns error if already registered with another profile", %{
      conn: conn,
      instance: instance,
      account: account,
      profile: profile,
      profile2: profile2,
      faction: faction
    } do
      conn =
        conn
        |> login(account)
        |> post(Routes.registration_path(conn, :join, profile.id), %{instance_id: instance.id, faction_id: faction.id})

      conn =
        build_conn()
        |> login(account)
        |> post(Routes.registration_path(conn, :join, profile2.id), %{instance_id: instance.id, faction_id: faction.id})

      assert json_response(conn, :conflict)["message"] == "already_registered"
    end

    test "returns error if already registered in another faction with another profile", %{
      conn: conn,
      instance: instance,
      account: account,
      profile: profile,
      profile2: profile2,
      faction: faction,
      faction2: faction2
    } do
      conn =
        conn
        |> login(account)
        |> post(Routes.registration_path(conn, :join, profile.id), %{instance_id: instance.id, faction_id: faction.id})

      conn =
        build_conn()
        |> login(account)
        |> post(Routes.registration_path(conn, :join, profile2.id), %{instance_id: instance.id, faction_id: faction2.id})

      assert json_response(conn, :conflict)["message"] == "already_registered"
    end

    test "registers a profile into a running instance if the instance is in late_registration mode", %{
      conn: conn,
      instance: _instance,
      account: account,
      profile: profile,
      faction: _faction
    } do
      %{instance: instance} = RC.ScenarioFixtures.valid_instance_fixture(true)
      faction = hd(instance.factions)
      admin_account = fixture(:admin)

      conn =
        conn
        |> login(admin_account)
        |> put(Routes.instance_path(conn, :publish, instance.id))

      assert json_response(conn, 200)["message"] == "instance_published"

      conn =
        build_conn()
        |> login(admin_account)
        |> put(Routes.instance_path(conn, :start, instance.id))

      assert json_response(conn, 200)["message"] == "instance_started"

      conn =
        build_conn()
        |> login(account)
        |> post(Routes.registration_path(conn, :join, profile.id), %{instance_id: instance.id, faction_id: faction.id})

      assert json_response(conn, 200)["message"] == "registered"
      assert {:ok, _} = Instance.Manager.destroy(instance.id)
    end

    test "returns error if registers a profile into a running instance in pre_registration mode", %{
      conn: conn,
      instance: _instance,
      account: account,
      profile: profile,
      faction: _faction
    } do
      %{instance: instance} = RC.ScenarioFixtures.valid_instance_fixture()
      faction = hd(instance.factions)
      admin_account = fixture(:admin)

      conn =
        conn
        |> login(admin_account)
        |> put(Routes.instance_path(conn, :publish, instance.id))

      assert json_response(conn, 200)["message"] == "instance_published"

      conn =
        build_conn()
        |> login(admin_account)
        |> put(Routes.instance_path(conn, :start, instance.id))

      assert json_response(conn, 200)["message"] == "instance_started"

      conn =
        build_conn()
        |> login(account)
        |> post(Routes.registration_path(conn, :join, profile.id), %{instance_id: instance.id, faction_id: faction.id})

      assert json_response(conn, 403)["message"] == "instance_in_pre_registration_mode"
      assert {:ok, _} = Instance.Manager.destroy(instance.id)
    end
  end

  describe "unregister" do
    setup [:instance_and_account_fixture]

    test "registers and unregisters a profile", %{
      conn: conn,
      instance: instance,
      account: account,
      profile: profile,
      faction: faction
    } do
      conn =
        conn
        |> login(account)
        |> post(Routes.registration_path(conn, :join, profile.id), %{
          instance_id: instance.id,
          faction_id: faction.id
        })

      assert json_response(conn, 200)

      conn =
        build_conn()
        |> login(account)
        |> put(Routes.registration_path(conn, :unjoin, profile.id), %{faction_id: faction.id})

      registration = RC.Registrations.get(%{faction_id: faction.id, profile_id: profile.id})

      assert json_response(conn, 200)["message"] == "profile_unregistered"
      assert is_nil(registration)
      assert RC.Repo.aggregate(RC.Instances.RegistrationState, :count) == 0
    end

    test "re-registers", %{
      conn: conn,
      instance: instance,
      account: account,
      profile: profile,
      faction: faction
    } do
      signed_in = login(conn, account)

      conn =
        signed_in
        |> post(Routes.registration_path(conn, :join, profile.id), %{
          instance_id: instance.id,
          faction_id: faction.id
        })

      assert json_response(conn, 200)

      conn =
        signed_in
        |> put(Routes.registration_path(conn, :unjoin, profile.id), %{faction_id: faction.id})

      conn =
        signed_in
        |> post(Routes.registration_path(conn, :join, profile.id), %{
          instance_id: instance.id,
          faction_id: faction.id
        })

      registration = RC.Registrations.get(%{faction_id: faction.id, profile_id: profile.id})

      assert json_response(conn, 200)["message"] == "registered"
      assert registration.state == "joined"
      assert RC.Repo.aggregate(RC.Instances.RegistrationState, :count) == 1
    end
  end

  describe "index" do
    setup [:instance_and_account_fixture]

    test "registers a profile into an instance", %{
      conn: conn,
      instance: instance,
      account: account,
      profile: profile,
      faction: faction
    } do
      conn =
        conn
        |> login(account)
        |> get(Routes.registration_path(conn, :index_by_instance, instance.id))

      [] = json_response(conn, 200)

      assert nil == RC.Registrations.get(%{faction_id: faction.id, profile_id: profile.id})

      conn =
        conn
        |> post(Routes.registration_path(conn, :join, profile.id), %{
          instance_id: instance.id,
          faction_id: faction.id
        })

      assert json_response(conn, 200)

      conn =
        build_conn()
        |> login(account)
        |> get(Routes.registration_path(conn, :index_by_instance, instance.id))

      [returned_registration] = json_response(conn, 200)

      registration = RC.Registrations.get(%{faction_id: faction.id, profile_id: profile.id})

      assert returned_registration["id"] == registration.id
      assert returned_registration["state"] == "joined"
    end

    test "returns error if instance does not exist", %{
      conn: conn,
      instance: instance,
      account: account
    } do
      conn =
        conn
        |> login(account)
        |> get(Routes.registration_path(conn, :index_by_instance, instance.id * 2))

      assert json_response(conn, 404)["message"] == "instance_not_found"
    end
  end
end
