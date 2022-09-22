defmodule Portal.InstanceControllerTest do
  use Portal.APIConnCase, async: false
  import RC.Fixtures
  import RC.ScenarioFixtures

  alias RC.Groups
  alias RC.Instances
  alias RC.Registrations

  @stored_file_path File.cwd!() <>
                      "/" <>
                      Application.compile_env(:waffle, :storage_dir) <>
                      "/"

  @instance_valid_attrs %{
    "description" => "some description",
    "name" => "some name",
    "opening_date" => "2010-04-17T14:00:00.000000Z",
    "registration_type" => "pre_registration",
    "registration_status" => "closed",
    "game_type" => "official",
    "public" => true,
    "start_setting" => "auto",
    "factions" => [%{"key" => "tetrarchy", "capacity" => 10}, %{"key" => "myrmezir", "capacity" => 10}]
  }

  @instance_update_attrs %{
    "game_data" => %{"data" => "some updated data"},
    "name" => "some updated name",
    "opening_date" => "2011-05-18T15:01:01.000000Z",
    "registration_type" => "late_registration",
    "registration_status" => "closed",
    "game_type" => "private",
    "start_setting" => "manual"
  }

  @instance_invalid_attrs %{
    "game_data" => nil,
    "name" => nil,
    "opening_date" => nil,
    "registration_type" => nil,
    "registration_status" => nil,
    "game_type" => nil,
    "start_setting" => nil,
    "factions" => []
  }

  setup %{conn: conn} do
    # To avoid crash in lib/game/instance/faction/faction.ex L37
    _key1 = :tetrarchy
    _key2 = :myrmezir

    on_exit(fn -> File.rm_rf(@stored_file_path) end)
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index as user" do
    setup [:create_account_user, :create_scenario]

    test "lists all instances", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> get(Routes.instance_path(conn, :index))

      assert json_response(conn, 200) == []
    end

    test "lists no instances if the instances are not published", %{
      conn: conn,
      account: account_user,
      scenario: scenario
    } do
      account_admin = fixture(:admin)

      # create instance 1
      conn =
        conn
        |> login(account_admin)
        |> post(Routes.instance_path(conn, :create), %{
          instance: @instance_valid_attrs,
          scenario_id: scenario.id
        })

      assert json_response(conn, 201)

      conn =
        build_conn()
        |> login(account_user)
        |> get(Routes.instance_path(conn, :index))

      assert json_response(conn, 200) == []
    end

    test "lists all instances with group access and instances not in a group", %{
      conn: conn,
      account: account_user,
      scenario: scenario
    } do
      account_admin = fixture(:admin)
      admin_conn = login(conn, account_admin)

      # create instance 1
      conn =
        conn
        |> login(account_admin)
        |> post(Routes.instance_path(conn, :create), %{
          instance: @instance_valid_attrs |> Map.put("description", "description instance1"),
          scenario_id: scenario.id
        })

      assert %{"id" => iid1} = json_response(conn, 201)

      # create instance 2
      conn =
        post(admin_conn, Routes.instance_path(conn, :create), %{
          instance: @instance_valid_attrs |> Map.put("description", "description instance2"),
          scenario_id: scenario.id
        })

      assert %{"id" => iid2} = json_response(conn, 201)

      # create instance 3
      conn =
        post(admin_conn, Routes.instance_path(conn, :create), %{
          instance: @instance_valid_attrs |> Map.put("description", "description instance3"),
          scenario_id: scenario.id
        })

      assert %{"id" => iid3} = json_response(conn, 201)

      # publish the instances
      conn = put(admin_conn, Routes.instance_path(conn, :publish, iid1))
      assert json_response(conn, 200)["message"] == "instance_published"

      conn = put(admin_conn, Routes.instance_path(conn, :publish, iid2))
      assert json_response(conn, 200)["message"] == "instance_published"

      conn = put(admin_conn, Routes.instance_path(conn, :publish, iid3))
      assert json_response(conn, 200)["message"] == "instance_published"

      # create two groups
      group1 = fixture(:group)
      group2 = fixture(:group)

      # add user and admin to group1
      {:ok, _group_with_accounts} = Groups.insert_accounts(group1, [account_user.id, account_admin.id])
      # add instance1 to group1
      {:ok, _group_with_instances} = Groups.insert_instances(group1, [iid1])

      # add admin to group2
      {:ok, _group_with_accounts} = Groups.insert_accounts(group2, [account_admin.id])
      # add instance2 to group2
      {:ok, _group_with_instances} = Groups.insert_instances(group2, [iid2])

      # instance1 <> group1 <> user,admin
      # instance2 <> group2 <> admin
      # instance3 <> no group

      # only two instances should show up:
      # instance1 because user is in the group to which this instance belongs, and
      # instance3 because it is not in any group
      conn =
        build_conn()
        |> login(account_user)
        |> get(Routes.instance_path(conn, :index))

      assert length(json_response(conn, 200)) == 2

      [i1, i3] =
        json_response(conn, 200)
        |> Enum.sort_by(& &1["id"])

      assert i3["description"] == "description instance3"
      assert i3["id"] == iid3
      assert i1["description"] == "description instance1"
      assert i1["id"] == iid1
    end
  end

  describe "index as admin" do
    setup [:create_account_admin, :create_scenario]

    test "lists all instances with group access", %{conn: conn, account: account_admin, scenario: scenario} do
      # create instance 1
      conn =
        conn
        |> login(account_admin)
        |> post(Routes.instance_path(conn, :create), %{instance: @instance_valid_attrs, scenario_id: scenario.id})

      assert %{"id" => iid1} = json_response(conn, 201)

      # create instance 2
      conn =
        build_conn()
        |> login(account_admin)
        |> post(Routes.instance_path(conn, :create), %{
          instance: @instance_valid_attrs |> Map.put("description", "some other description"),
          scenario_id: scenario.id
        })

      assert %{"id" => iid2} = json_response(conn, 201)

      # give access to both user instance 1 (but not instance 2)
      group = fixture(:group)

      {:ok, _group_with_accounts} = Groups.insert_accounts(group, [account_admin.id])
      {:ok, _group_with_instances} = Groups.insert_instances(group, [iid1])

      # check if only instance 1 shows up
      conn =
        build_conn()
        |> login(account_admin)
        |> get(Routes.instance_path(conn, :index))

      instances =
        json_response(conn, 200)
        |> Enum.sort_by(& &1["id"])

      assert length(instances) == 2

      assert [
               %{"description" => descr, "id" => id},
               %{"description" => descr2, "id" => id2}
             ] = instances

      assert id == iid1
      assert id2 == iid2
      assert descr == "some description"
      assert descr2 == "some other description"
    end

    test "lists filtered instances", %{conn: conn, account: account_admin} do
      %{instance: instance} = valid_instance_fixture()

      conn =
        build_conn()
        |> login(account_admin)
        |> get(Routes.instance_path(conn, :index, %{speed: "fast"}))

      [returned_instance] = json_response(conn, 200)

      assert returned_instance["name"] == instance.name
    end

    test "lists filtered instances by state", %{conn: conn, account: account_admin} do
      %{instance: instance1} = valid_instance_fixture()
      %{instance: instance2} = valid_instance_fixture()
      %{instance: instance3} = valid_instance_fixture()

      {:ok, _instance1} = Instances.publish_instance(instance1, account_admin.id)
      {:ok, instance2} = Instances.publish_instance(instance2, account_admin.id)
      {:ok, instance3} = Instances.publish_instance(instance3, account_admin.id)

      {:ok, _updated_instance} = Instances.start_instance(instance2, account_admin.id)
      {:ok, %{instance: instance3}} = Instances.start_instance(instance3, account_admin.id)

      {:ok, _updated_instance} = Instances.pause_instance(instance3, account_admin.id)

      conn =
        build_conn()
        |> login(account_admin)
        |> get(Routes.instance_path(conn, :index, %{state: "open,running"}))

      returned_instances = json_response(conn, 200)
      assert length(returned_instances) == 2

      [i1, i2] =
        returned_instances
        |> Enum.sort_by(& &1["id"])

      assert i1["state"] == "open"
      assert i2["state"] == "running"
    end
  end

  describe "create instance as admin" do
    setup [:create_account_admin, :create_scenario]

    test "renders instance when data is valid", %{conn: conn, account: account, scenario: scenario} do
      group = fixture(:group)

      {:ok, _group_with_accounts} = Groups.insert_accounts(group, [account.id])

      conn =
        conn
        |> login(account)
        |> post(Routes.instance_path(conn, :create), %{instance: @instance_valid_attrs, scenario_id: scenario.id})

      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, Routes.instance_path(conn, :show, id))

      returned_instance = json_response(conn, 200)
      assert returned_instance["description"] == @instance_valid_attrs["description"]
      assert returned_instance["name"] == @instance_valid_attrs["name"]
      assert returned_instance["game_type"] == @instance_valid_attrs["game_type"]
      assert returned_instance["public"] == @instance_valid_attrs["public"]
      assert returned_instance["registration_type"] == @instance_valid_attrs["registration_type"]
      assert returned_instance["start_setting"] == @instance_valid_attrs["start_setting"]
      assert returned_instance["registration_status"] == @instance_valid_attrs["registration_status"]
    end

    test "renders errors when data is invalid", %{conn: conn, account: account, scenario: scenario} do
      conn =
        conn
        |> login(account)
        |> post(Routes.instance_path(conn, :create), instance: @instance_invalid_attrs, scenario_id: scenario.id)

      assert json_response(conn, 400)
    end

    test "renders errors when scenario id is invalid", %{conn: conn, account: account, scenario: scenario} do
      conn =
        conn
        |> login(account)
        |> post(Routes.instance_path(conn, :create), instance: @instance_invalid_attrs, scenario_id: scenario.id * 2)

      assert json_response(conn, 404)["message"] == "scenario_not_found"
    end

    defp create_scenario(_) do
      scenario = scenario_fixture()
      {:ok, scenario: scenario}
    end
  end

  describe "update instance" do
    setup [:create_instance, :create_account_user]

    test "renders instance when data is valid", %{conn: conn, instance: instance, owner_account: account} do
      group = fixture(:group)

      {:ok, _group_with_accounts} = Groups.insert_accounts(group, [account.id])
      {:ok, _group_with_instances} = Groups.insert_instances(group, [instance.id])

      conn =
        conn
        |> login(account)
        |> put(Routes.instance_path(conn, :update, instance), instance: @instance_update_attrs)

      assert %{"id" => id} = json_response(conn, 200)

      conn = get(conn, Routes.instance_path(conn, :show, id))

      assert @instance_update_attrs = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, instance: instance, owner_account: account} do
      group = fixture(:group)

      {:ok, _group_with_accounts} = Groups.insert_accounts(group, [account.id])
      {:ok, _group_with_instances} = Groups.insert_instances(group, [instance.id])

      conn =
        conn
        |> login(account)
        |> put(Routes.instance_path(conn, :update, instance), instance: @instance_invalid_attrs)

      assert json_response(conn, 400)
    end

    test "returns forbidden if not owner", %{conn: conn, instance: instance, account: account} do
      group = fixture(:group)
      {:ok, _group_with_accounts} = Groups.insert_accounts(group, [account.id])
      {:ok, _group_with_instances} = Groups.insert_instances(group, [instance.id])

      conn =
        conn
        |> login(account)
        |> put(Routes.instance_path(conn, :update, instance), instance: @instance_update_attrs)

      assert json_response(conn, 403)["message"] == "forbidden"
    end
  end

  describe "delete instance as admin" do
    setup [:create_instance]
    setup [:create_account_admin]

    test "deletes chosen instance", %{conn: conn, instance: instance, account: account} do
      group = fixture(:group)
      {:ok, _group_with_accounts} = Groups.insert_accounts(group, [account.id])
      {:ok, _group_with_instances} = Groups.insert_instances(group, [instance.id])

      conn =
        conn
        |> login(account)
        |> delete(Routes.instance_path(conn, :delete, instance))

      assert response(conn, 204)

      conn = get(conn, Routes.instance_path(conn, :show, instance.id))
      assert json_response(conn, 404)["message"] == "not_found"
    end
  end

  describe "delete instance as user" do
    setup [:create_instance]
    setup [:create_account_user]

    test "returns forbidden if not owner", %{conn: conn, instance: instance, account: account} do
      group = fixture(:group)
      {:ok, _group_with_accounts} = Groups.insert_accounts(group, [account.id])
      {:ok, _group_with_instances} = Groups.insert_instances(group, [instance.id])

      conn =
        conn
        |> login(account)
        |> delete(Routes.instance_path(conn, :delete, instance))

      assert json_response(conn, 403)["message"] == "forbidden"
    end

    test "deletes the instance if owner", %{conn: conn, instance: instance, owner_account: account} do
      group = fixture(:group)
      {:ok, _group_with_accounts} = Groups.insert_accounts(group, [account.id])
      {:ok, _group_with_instances} = Groups.insert_instances(group, [instance.id])

      conn =
        conn
        |> login(account)
        |> delete(Routes.instance_path(conn, :delete, instance))

      assert response(conn, 204)
    end
  end

  describe "publish" do
    setup [:create_instance]

    test "changes the state of the instance", %{conn: conn, instance: instance, owner_account: account} do
      conn =
        conn
        |> login(account)
        |> put(Routes.instance_path(conn, :publish, instance.id))

      assert json_response(conn, 200)["message"] == "instance_published"
      assert RC.Instances.get_instance(instance.id).state == "open"
    end
  end

  describe "start" do
    alias RC.Accounts.Profile
    alias RC.Repo

    test "can start an instance", %{conn: conn} do
      %{instance: instance, account: account} = RC.ScenarioFixtures.valid_instance_fixture()

      signed_in = login(conn, account)

      conn = put(signed_in, Routes.instance_path(conn, :publish, instance.id))
      assert json_response(conn, 200)["message"] == "instance_published"

      profile_params = %{avatar: "TODO", name: account.name, account_id: account.id}

      {:ok, profile} = Repo.insert(Profile.changeset(%Profile{}, profile_params))

      faction = hd(instance.factions)

      conn =
        post(signed_in, Routes.registration_path(conn, :join, profile.id), %{
          instance_id: instance.id,
          faction_id: faction.id
        })

      assert json_response(conn, 200)["message"] == "registered"
      assert Registrations.get(%{faction_id: faction.id, profile_id: profile.id}).state == "joined"

      conn = put(signed_in, Routes.instance_path(conn, :start, instance.id))
      assert json_response(conn, 200)["message"] == "instance_started"
      {:ok, :killed} = Instance.Manager.destroy(instance.id)
    end
  end

  describe "state machine" do
    alias RC.Accounts.Profile
    alias RC.Repo

    test "can do the transition to maintenance and previous state correctly", %{conn: conn} do
      # i1: open
      %{instance: i1, account: _account} = RC.ScenarioFixtures.valid_instance_fixture()
      # i2: running
      %{instance: i2, account: _account} = RC.ScenarioFixtures.valid_instance_fixture()
      # i3: paused
      %{instance: i3, account: account} = RC.ScenarioFixtures.valid_instance_fixture()

      signed_in = login(conn, account)

      # Instance 1
      conn = put(signed_in, Routes.instance_path(conn, :publish, i1.id))
      assert json_response(conn, 200)["message"] == "instance_published"

      # Instance 2
      conn = put(signed_in, Routes.instance_path(conn, :publish, i2.id))
      assert json_response(conn, 200)["message"] == "instance_published"

      conn = put(signed_in, Routes.instance_path(conn, :start, i2.id))
      assert json_response(conn, 200)["message"] == "instance_started"

      # Instance 3
      conn = put(signed_in, Routes.instance_path(conn, :publish, i3.id))
      assert json_response(conn, 200)["message"] == "instance_published"

      conn = put(signed_in, Routes.instance_path(conn, :start, i3.id))
      assert json_response(conn, 200)["message"] == "instance_started"

      conn = put(signed_in, Routes.instance_path(conn, :pause, i3.id))
      assert json_response(conn, 200)["message"] == "instance_paused"

      i1 = Instances.get_instance(i1.id)
      i2 = Instances.get_instance(i2.id)
      i3 = Instances.get_instance(i3.id)

      [i1, i2, i3]
      |> Enum.each(fn instance ->
        {:ok, _} = Instances.maintenance_instance(instance, account.id)
      end)

      i1 = Instances.get_instance(i1.id)
      i2 = Instances.get_instance(i2.id)
      i3 = Instances.get_instance(i3.id)
      assert i1.state == "maintenance"
      assert i2.state == "maintenance"
      assert i3.state == "maintenance"

      # wait for supervisor to be correctly killed
      :timer.sleep(10000)

      [i1, i2, i3]
      |> Enum.each(fn instance ->
        {:ok, _} = Instances.restore_instance(instance, account.id)
      end)

      # assert maintenance_errors_cnt == 0

      i1 = Instances.get_instance(i1.id)
      i2 = Instances.get_instance(i2.id)
      i3 = Instances.get_instance(i3.id)
      assert i1.state == "open"
      assert i2.state == "running"
      assert i3.state == "paused"
    end

    test "can do the transitions correctly and deletes the instance", %{conn: conn} do
      %{instance: instance, account: account} = RC.ScenarioFixtures.valid_instance_fixture()

      signed_in = login(conn, account)

      conn = put(signed_in, Routes.instance_path(conn, :publish, instance.id))
      assert json_response(conn, 200)["message"] == "instance_published"

      profile_params = %{avatar: "TODO", name: account.name, account_id: account.id}

      {:ok, profile} = Repo.insert(Profile.changeset(%Profile{}, profile_params))

      faction = hd(instance.factions)

      conn =
        post(signed_in, Routes.registration_path(conn, :join, profile.id), %{
          instance_id: instance.id,
          faction_id: faction.id
        })

      assert json_response(conn, 200)["message"] == "registered"
      assert Registrations.get(%{faction_id: faction.id, profile_id: profile.id}).state == "joined"

      conn = put(signed_in, Routes.instance_path(conn, :start, instance.id))
      assert json_response(conn, 200)["message"] == "instance_started"
      assert Registrations.get(%{faction_id: faction.id, profile_id: profile.id}).state == "playing"

      conn = delete(signed_in, Routes.instance_path(conn, :delete, instance.id))
      assert json_response(conn, 403)["message"] == "bad_instance_state_for_delete"

      conn = put(signed_in, Routes.instance_path(conn, :pause, instance.id))
      assert json_response(conn, 200)["message"] == "instance_paused"

      conn = delete(signed_in, Routes.instance_path(conn, :delete, instance.id))
      assert json_response(conn, 403)["message"] == "bad_instance_state_for_delete"

      conn = put(signed_in, Routes.instance_path(conn, :resume, instance.id))
      assert json_response(conn, 200)["message"] == "instance_resumed"

      conn = put(signed_in, Routes.instance_path(conn, :finish, instance.id))
      assert json_response(conn, 200)["message"] == "instance_killed_and_finished"

      # DB is used when killing the processes
      :timer.sleep(15000)

      conn = delete(signed_in, Routes.instance_path(conn, :delete, instance.id))

      assert response(conn, 204)
    end

    test "returns forbidden if not instance owner", %{conn: conn} do
      %{instance: instance, account: _account} = RC.ScenarioFixtures.valid_instance_fixture()

      {:ok, account: account} = RC.Fixtures.create_account_user(%{})

      conn =
        conn
        |> login(account)
        |> put(Routes.instance_path(conn, :publish, instance.id))

      assert json_response(conn, 403)["message"] == "forbidden"
    end

    test "stops the instance if the supervisor is unexpectedly killed", %{conn: conn} do
      %{instance: instance, account: account} = RC.ScenarioFixtures.valid_instance_fixture()

      signed_in = login(conn, account)
      conn = put(signed_in, Routes.instance_path(conn, :publish, instance.id))

      assert json_response(conn, 200)["message"] == "instance_published"

      profile_params = %{avatar: "TODO", name: account.name, account_id: account.id}

      {:ok, profile} = Repo.insert(Profile.changeset(%Profile{}, profile_params))

      faction = hd(instance.factions)

      conn =
        post(signed_in, Routes.registration_path(conn, :join, profile.id), %{
          instance_id: instance.id,
          faction_id: faction.id
        })

      assert json_response(conn, 200)["message"] == "registered"
      assert Registrations.get(%{faction_id: faction.id, profile_id: profile.id}).state == "joined"

      :timer.sleep(100)

      conn = put(signed_in, Routes.instance_path(conn, :start, instance.id))
      assert json_response(conn, 200)["message"] == "instance_started"
      assert Registrations.get(%{faction_id: faction.id, profile_id: profile.id}).state == "playing"

      {:ok, :killed} = Instance.Manager.destroy(instance.id)

      RC.Instances.update_instances_state_if_needed(true)

      conn = get(signed_in, Routes.instance_path(conn, :index))

      returned_instances = json_response(conn, 200)
      returned_instance = hd(returned_instances)

      assert returned_instance["id"] == instance.id
      assert returned_instance["state"] == "not_running"
      assert length(returned_instances) == 1
    end

    test "can start the instance from :not_running state if the supervisor is unexpectedly killed", %{conn: conn} do
      %{instance: instance, account: account} = RC.ScenarioFixtures.valid_instance_fixture()

      signed_in = login(conn, account)

      conn = put(signed_in, Routes.instance_path(conn, :publish, instance.id))
      assert json_response(conn, 200)["message"] == "instance_published"

      profile_params = %{avatar: "TODO", name: account.name, account_id: account.id}

      {:ok, profile} = Repo.insert(Profile.changeset(%Profile{}, profile_params))

      faction = hd(instance.factions)

      conn =
        post(signed_in, Routes.registration_path(conn, :join, profile.id), %{
          instance_id: instance.id,
          faction_id: faction.id
        })

      assert json_response(conn, 200)["message"] == "registered"
      assert Registrations.get(%{faction_id: faction.id, profile_id: profile.id}).state == "joined"

      :timer.sleep(100)

      conn = put(signed_in, Routes.instance_path(conn, :start, instance.id))
      assert json_response(conn, 200)["message"] == "instance_started"
      assert Registrations.get(%{faction_id: faction.id, profile_id: profile.id}).state == "playing"

      :timer.sleep(100)

      {:ok, :killed} = Instance.Manager.destroy(instance.id)

      :timer.sleep(15000)

      RC.Instances.update_instances_state_if_needed(true)

      conn = put(signed_in, Routes.instance_path(conn, :start, instance.id))
      assert json_response(conn, 200)["message"] == "instance_restarted"
    end

    test "can stop the instance from :not_running state if the supervisor is unexpectedly killed", %{conn: conn} do
      %{instance: instance, account: account} = RC.ScenarioFixtures.valid_instance_fixture()

      signed_in = login(conn, account)

      conn = put(signed_in, Routes.instance_path(conn, :publish, instance.id))
      assert json_response(conn, 200)["message"] == "instance_published"

      profile_params = %{avatar: "TODO", name: account.name, account_id: account.id}

      {:ok, profile} = Repo.insert(Profile.changeset(%Profile{}, profile_params))

      faction = hd(instance.factions)

      conn =
        post(signed_in, Routes.registration_path(conn, :join, profile.id), %{
          instance_id: instance.id,
          faction_id: faction.id
        })

      assert json_response(conn, 200)["message"] == "registered"
      assert Registrations.get(%{faction_id: faction.id, profile_id: profile.id}).state == "joined"

      :timer.sleep(100)

      conn = put(signed_in, Routes.instance_path(conn, :start, instance.id))
      assert json_response(conn, 200)["message"] == "instance_started"
      assert Registrations.get(%{faction_id: faction.id, profile_id: profile.id}).state == "playing"

      :timer.sleep(100)

      refute RC.Instances.update_instances_state_if_needed() |> Enum.map(& &1.id) |> Enum.member?(instance.id)

      {:ok, :killed} = Instance.Manager.destroy(instance.id)

      :timer.sleep(15000)

      assert RC.Instances.update_instances_state_if_needed() |> Enum.map(& &1.id) |> Enum.member?(instance.id)
      RC.Instances.update_instances_state_if_needed(true)

      conn = put(signed_in, Routes.instance_path(conn, :finish, instance.id))
      assert json_response(conn, 200)["message"] == "instance_finished"
    end

    test "can stop the instance from paused state ", %{conn: conn} do
      %{instance: instance, account: account} = RC.ScenarioFixtures.valid_instance_fixture()
      signed_in = login(conn, account)

      conn = put(signed_in, Routes.instance_path(conn, :publish, instance.id))
      assert json_response(conn, 200)["message"] == "instance_published"

      profile_params = %{avatar: "TODO", name: account.name, account_id: account.id}

      {:ok, profile} = Repo.insert(Profile.changeset(%Profile{}, profile_params))

      faction = hd(instance.factions)

      conn =
        post(signed_in, Routes.registration_path(conn, :join, profile.id), %{
          instance_id: instance.id,
          faction_id: faction.id
        })

      assert json_response(conn, 200)["message"] == "registered"
      assert Registrations.get(%{faction_id: faction.id, profile_id: profile.id}).state == "joined"

      :timer.sleep(100)

      conn = put(signed_in, Routes.instance_path(conn, :start, instance.id))
      assert json_response(conn, 200)["message"] == "instance_started"
      assert Registrations.get(%{faction_id: faction.id, profile_id: profile.id}).state == "playing"

      :timer.sleep(100)

      conn = put(signed_in, Routes.instance_path(conn, :pause, instance.id))
      assert json_response(conn, 200)["message"] == "instance_paused"
      assert Instances.get_instance(instance.id).state == "paused"

      :timer.sleep(100)

      conn = put(signed_in, Routes.instance_path(conn, :finish, instance.id))
      assert json_response(conn, 200)["message"] == "instance_killed_and_finished"
    end
  end

  def create_instance(_) do
    %{instance: instance, account: account} = instance_fixture()
    {:ok, instance: instance, owner_account: account}
  end
end
