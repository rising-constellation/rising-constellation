defmodule RC.InstancesTest do
  use RC.DataCase

  import RC.Fixtures
  import RC.ScenarioFixtures

  alias RC.Accounts.Profile
  alias RC.Instances
  alias RC.InstanceSnapshots
  alias RC.Registrations

  @stored_file_path File.cwd!() <>
                      "/" <>
                      Application.compile_env(:waffle, :storage_dir) <>
                      "/"

  @instance_valid_attrs %{
    "description" => "some description",
    "name" => "some name",
    "opening_date" => "2010-04-17T14:00:00Z",
    "registration_type" => "pre_registration",
    "registration_status" => "open",
    "game_type" => "official",
    "public" => true,
    "start_setting" => "auto",
    "factions" => [%{"key" => "tetrarchy", "capacity" => 10}, %{"key" => "myrmezir", "capacity" => 10}],
    "state" => "created"
  }
  @instance_update_attrs %{
    "game_data" => %{"data" => "some updated data"},
    "name" => "some updated name",
    "opening_date" => "2011-05-18T15:01:01Z",
    "registration_type" => "late_registration",
    "registration_status" => "closed",
    "game_type" => "private",
    "start_setting" => "manual",
    "state" => "created"
  }

  @instance_invalid_attrs %{
    "game_data" => nil,
    "name" => nil,
    "opening_date" => nil,
    "registration_type" => nil,
    "registration_status" => nil,
    "game_type" => nil,
    "factions" => [],
    "state" => "created"
  }

  setup do
    # To avoid crash in lib/game/instance/faction/faction.ex L37
    _key1 = :tetrarchy
    _key2 = :myrmezir

    on_exit(fn -> File.rm_rf(@stored_file_path) end)
  end

  describe "instances" do
    setup [:create_account_admin]
    alias RC.Instances.Instance

    @nil_attrs %{
      "game_data" => nil,
      "game_status" => nil,
      "name" => nil,
      "opening_date" => nil,
      "status" => nil
    }

    test "list_instances/2 returns all instances" do
      %{instance: instance} = instance_fixture()

      {:ok, list_instances} = Instances.list_instances(%{}, :count_registrations)

      assert list_instances.total_entries == 1
      assert length(list_instances.entries) == 1

      [listed_instance] = list_instances.entries

      assert Map.drop(listed_instance, [:states]) ==
               instance
               |> Map.put(:supervisor_status, :not_instantiated)
               |> Map.put(:node, "")
               |> Map.drop([:states])
    end

    test "list_instances/2 returns all instances after state transition", %{account: account} do
      %{instance: instance} = instance_fixture()

      {:ok, _instance} = Instances.publish_instance(instance, account.id)

      {:ok, list_instances} = Instances.list_instances(%{}, :count_registrations)

      assert length(list_instances.entries) == 1

      [listed_instance] = list_instances.entries

      assert Map.drop(listed_instance, [:updated_at]) ==
               instance
               |> Map.put(:supervisor_status, :not_instantiated)
               |> Map.put(:node, "")
               |> Map.put(:state, "open")
               |> Map.put(:registration_status, :open)
               |> Map.drop([:updated_at])
    end

    test "list_instances/2 returns filtered by state instances if state is in the filters", %{account: account} do
      %{instance: instance} = instance_fixture()
      %{instance: _instance2} = instance_fixture()

      {:ok, list_instances} = Instances.list_instances(%{}, :count_registrations)

      assert length(list_instances.entries) == 2

      # publish only one instance, so that the state is "open"
      {:ok, _instance} = Instances.publish_instance(instance, account.id)

      {:ok, list_instances} = Instances.list_instances(%{"state" => "open"}, :count_registrations)

      assert length(list_instances.entries) == 1
      assert hd(list_instances.entries).state == "open"
      assert hd(list_instances.entries).id == instance.id
    end

    test "get_instance/1 returns the instance with given id" do
      %{instance: instance} = instance_fixture()

      assert Instances.get_instance(instance.id) ==
               instance
               |> Map.put(:supervisor_status, :not_instantiated)
               |> Map.put(:node, "")
               |> Map.put(:state, "created")
               |> Map.put(:groups, [])
    end

    test "create_instance/1 with valid data creates a instance" do
      scenario = scenario_fixture()
      {:ok, account: account} = create_account_user(%{})

      {:ok, %{instance: instance, instance_state: instance_state}} =
        Instances.create_instance(@instance_valid_attrs, scenario, account.id)

      assert instance.game_data == %{
               "data" => "some data"
             }

      assert instance.registration_status == :closed
      assert instance.game_type == :official
      assert instance.public == true
      assert instance.name == "some name"
      assert instance.opening_date == DateTime.from_naive!(~N[2010-04-17T14:00:00.000000Z], "Etc/UTC")
      assert instance_state.state == "created"
      assert length(instance.factions) == 2
      assert instance.start_setting == :auto
    end

    test "create_instance/1 with nil attrs returns error ArgumentError" do
      scenario = scenario_fixture()
      {:ok, account: account} = create_account_user(%{})

      assert {:error, _failed_operation, _failed_value, _changes_so_far} =
               Instances.create_instance(@nil_attrs, scenario, account.id)
    end

    test "update_instance/2 with valid data updates the instance" do
      %{instance: instance} = instance_fixture()

      assert {:ok, %Instance{} = instance} = Instances.update_instance(instance, @instance_update_attrs)
      assert instance.game_data == %{"data" => "some updated data"}
      assert instance.registration_type == :late_registration
      assert instance.game_type == :private
      assert instance.name == "some updated name"
      assert instance.opening_date == DateTime.from_naive!(~N[2011-05-18T15:01:01.000000Z], "Etc/UTC")
    end

    test "update_instance/2 with invalid data returns error changeset" do
      %{instance: instance} = instance_fixture()

      assert {:error, %Ecto.Changeset{}} = Instances.update_instance(instance, @instance_invalid_attrs)

      assert instance
             |> Map.put(:supervisor_status, :not_instantiated)
             |> Map.put(:node, "")
             |> Map.put(:state, "created")
             |> Map.put(:groups, []) == Instances.get_instance(instance.id)
    end

    test "delete_instance/1 deletes the instance" do
      %{instance: instance} = instance_fixture()

      assert {:ok, %Instance{}} = Instances.delete_instance(instance)
      assert Instances.get_instance(instance.id) == nil
    end

    test "delete_instance/1 deletes the instance after a profile registration" do
      {instance, _account, profile, faction} = instance_and_account_fixture()

      {:ok, %{registration: _registration, registration_state: _registration_state}} =
        Registrations.register_profile(faction, profile)

      registration_get = Registrations.get(%{faction_id: faction.id, profile_id: profile.id})

      assert registration_get.state == "joined"
      assert {:ok, %Instance{}} = Instances.delete_instance(instance)
      assert Instances.get_instance(instance.id) == nil
    end

    test "publish instance change the state to `open` and log the new state", %{account: account} do
      %{instance: instance} = instance_fixture()

      assert {:ok, updated_instance} = Instances.publish_instance(instance, account.id)
      assert updated_instance.state == "open"
      assert Instances.get_instance(instance.id).state == "open"
      assert RC.Repo.aggregate(RC.Instances.InstanceState, :count) == 2
    end

    test "full state machine is valid", %{account: account} do
      %{instance: instance} = instance_fixture()

      assert {:ok, instance} = Instances.publish_instance(instance, account.id)
      assert {:ok, %{instance: instance, registrations: _r}} = Instances.start_instance(instance, account.id)
      assert {:ok, instance} = Instances.pause_instance(instance, account.id)
      assert {:ok, instance} = Instances.resume_instance(instance, account.id)
      assert {:ok, instance} = Instances.close_instance(instance)
      assert {:ok, _instance} = Instances.finish_instance(instance, account.id)
    end

    test "start_instance/2 update the registration_status when pre_registration mode", %{account: account} do
      %{instance: instance} = instance_fixture()

      assert {:ok, instance} = Instances.publish_instance(instance, account.id)
      assert {:ok, %{instance: instance, registrations: _r}} = Instances.start_instance(instance, account.id)
      assert instance.registration_status == :closed
    end

    test "close_instance/2 update the registration_status when late_registration mode", %{account: account} do
      %{instance: instance} = instance_fixture(:late)

      assert {:ok, instance} = Instances.publish_instance(instance, account.id)
      assert {:ok, %{instance: instance, registrations: _r}} = Instances.start_instance(instance, account.id)
      assert instance.registration_status == :open
      assert {:ok, instance} = Instances.close_instance(instance)
      assert instance.registration_status == :closed
    end
  end

  describe "factions" do
    alias RC.Instances.Instance

    def faction_fixture() do
      %{instance: instance} = instance_fixture()

      instance.factions
    end

    test "get_faction/1 returns the faction with given id" do
      [faction, _faction2] = faction_fixture()

      assert Instances.get_faction(faction.id)
             |> Repo.preload(:instance)
             |> Map.delete(:registrations_count) ==
               faction |> Repo.preload(:instance) |> Map.delete(:registrations_count)
    end
  end

  describe "instance_snapshots" do
    alias RC.Instances.InstanceSnapshot

    @valid_attrs %{name: "some filename", size: 42}
    @invalid_attrs %{name: nil, size: nil}

    def instance_snapshot_fixture(attrs \\ %{}) do
      %{instance: instance} = instance_fixture()

      {:ok, instance_snapshot} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.put(:instance_id, instance.id)
        |> InstanceSnapshots.insert()

      instance_snapshot
    end

    test "get_snapshot/1 returns the instance_snapshot with given id" do
      instance_snapshot = instance_snapshot_fixture()
      assert InstanceSnapshots.get(instance_snapshot.id) == instance_snapshot
    end

    test "insert_snapshot/1 with valid data creates a instance_snapshot" do
      %{instance: instance} = instance_fixture()

      assert {:ok, %InstanceSnapshot{} = instance_snapshot} =
               InstanceSnapshots.insert(@valid_attrs |> Map.put(:instance_id, instance.id))

      assert instance_snapshot.name == "some filename"
      assert instance_snapshot.size == 42
    end

    test "insert_snapshot/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = InstanceSnapshots.insert(@invalid_attrs)
    end

    test "delete_snapshot/1 deletes the instance_snapshot" do
      instance_snapshot = instance_snapshot_fixture()
      assert {:ok, %InstanceSnapshot{}} = InstanceSnapshots.delete(instance_snapshot)
      assert nil == InstanceSnapshots.get(instance_snapshot.id)
    end
  end

  describe "registrations" do
    alias RC.Instances.Registration
    alias RC.Instances.RegistrationState

    def instance_and_account_fixture() do
      %{instance: instance} = instance_fixture()

      {:ok, account: account} = create_account_user(%{})

      profile_params = %{
        avatar: "TODO",
        name: account.name,
        account_id: account.id,
        full_name: "some full_name",
        description: "some description",
        long_description: "some long_description",
        age: 30
      }

      {:ok, profile} = Repo.insert(Profile.changeset(%Profile{}, profile_params))

      {instance, account, profile, hd(instance.factions)}
    end

    test "registration_valid?/2" do
      {instance, _account, profile, faction} = instance_and_account_fixture()

      {:ok, %{registration: registration}} = Registrations.register_profile(faction, profile)

      assert {:ok, _registration} = Registrations.valid?(instance.id, registration.token)
    end

    test "list_registrations/2 gets registrations given an instance" do
      {instance, _account, profile, faction} = instance_and_account_fixture()

      {:ok, _} = Registrations.register_profile(faction, profile)

      assert [registration] = Registrations.list(instance.id)
      assert registration.faction_id == faction.id
      assert registration.profile_id == profile.id
    end

    test "list_registrations/2 gets registrations given an instance after a registration transition" do
      {instance, _account, profile, faction} = instance_and_account_fixture()

      {:ok, %{registration: registration}} = Registrations.register_profile(faction, profile)

      {:ok, _} = Registrations.transition_to(%Registration{} = registration, "playing")

      assert [registration] = Registrations.list(instance.id)
      assert registration.faction_id == faction.id
      assert registration.profile_id == profile.id
      assert registration.state == "playing"
      assert length(registration.states) == 2
    end

    test "filter_by_state/2 get all the registrations" do
      {instance, _account, profile, faction} = instance_and_account_fixture()

      {:ok, %{registration: registration}} = Registrations.register_profile(faction, profile)

      {:ok, _} = Registrations.transition_to(%Registration{} = registration, "playing")

      assert [registration] = Registrations.filter_by_state(instance.id, "playing")
      assert registration.faction_id == faction.id
      assert registration.profile_id == profile.id
      assert registration.state == "playing"
    end

    test "register_profile/3 register a profile" do
      {_instance, _account, profile, faction} = instance_and_account_fixture()

      {:ok, %{registration: registration, registration_state: registration_state}} =
        Registrations.register_profile(faction, profile)

      registration_get = Registrations.get(%{faction_id: faction.id, profile_id: profile.id})

      assert registration_state.state == "joined"
      assert [registration |> Map.put(:state, "joined")] == RC.Repo.all(Registration)
      assert [registration_state] == RC.Repo.all(RegistrationState)
      assert registration_get.state == "joined"
    end

    test "start instance change the state to `running` and update the registrations" do
      {instance, account, profile, faction} = instance_and_account_fixture()

      {:ok, _} = Registrations.register_profile(faction, profile)

      {:ok, updated_instance} = Instances.publish_instance(instance, account.id)

      assert {:ok, %{instance: instance, registrations: [updated_registration] = updated_registrations}} =
               Instances.start_instance(updated_instance, account.id)

      assert instance.state == "running"
      assert length(updated_registrations) == 1
      assert updated_registration.state == "playing"
    end

    test "already_registered/2" do
      {instance, account, profile, faction} = instance_and_account_fixture()

      {:ok, _} = Registrations.register_profile(faction, profile)

      assert Registrations.registered?(%{instance_id: instance.id, account_id: account.id})
    end

    test "get_previous_instance_state/1 get the previous state" do
      {instance, account, profile, faction} = instance_and_account_fixture()

      {:ok, _} = Registrations.register_profile(faction, profile)

      {:ok, updated_instance} = Instances.publish_instance(instance, account.id)

      assert {:ok, %{instance: instance, registrations: _updated_registrations}} =
               Instances.start_instance(updated_instance, account.id)

      assert Instances.get_previous_instance_state(instance.id) == "open"
    end
  end
end
