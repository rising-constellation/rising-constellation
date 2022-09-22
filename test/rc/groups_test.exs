defmodule RC.GroupsTest do
  use RC.DataCase, async: true

  alias RC.Groups

  import RC.Fixtures
  import RC.ScenarioFixtures

  # alias RC.Fixtures
  describe "groups" do
    alias RC.Groups.Group
    # alias RC.Fixtures

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    test "list_groups/0 returns all groups" do
      group = fixture(:group)
      assert Groups.list_groups().entries == [group]
    end

    test "get_group/1 returns the group with given id" do
      group = fixture(:group)
      assert Groups.get_group(group.id) == group
    end

    test "create_group/1 with valid data creates a group" do
      assert {:ok, %Group{} = group} = Groups.create_group(@valid_attrs)
      assert group.name == "some name"
    end

    test "create_group/1 with admin as name returns error" do
      assert {:error, _error} = Groups.create_group(%{name: "admin"})
    end

    test "create_group/1 with blog-writer as name returns error" do
      blog_group_name = Application.get_env(:rc, RC.Groups) |> Keyword.get(:blog_group_name)
      assert {:error, _error} = Groups.create_group(%{name: blog_group_name})
    end

    test "insert_accounts/2 with valid account id add account" do
      account_user = fixture(:user)
      account_admin = fixture(:admin)

      group = fixture(:group)

      {:ok, _} = Groups.insert_accounts(group, [account_user.id, account_admin.id])

      grp = Groups.get_group(group.id)

      assert length(grp.accounts) == 2
      [id1, id2] = [account_user.id, account_admin.id]
      assert [^id1, ^id2] = grp.accounts |> Enum.map(& &1.id)
    end

    test "insert_accounts/2 with invalid account id returns error" do
      account_user = fixture(:user)

      group = fixture(:group)

      {:error, _failed_operation, _failed_value, _changes_so_far} = Groups.insert_accounts(group, [account_user.id * 2])

      grp = Groups.get_group(group.id)

      assert Enum.empty?(grp.accounts)
    end

    test "insert_accounts/2 with same id twice return errors" do
      account_user = fixture(:user)

      group = fixture(:group)

      assert {:ok, _reasons} = Groups.insert_accounts(group, [account_user.id])
      assert {:error, _reasons, _changeset, _changes} = Groups.insert_accounts(group, [account_user.id])
      assert length(Groups.get_group(group.id).accounts) == 1
    end

    test "insert_accounts/2 with same id twice at the same time return errors" do
      account_user = fixture(:user)

      group = fixture(:group)

      assert {:error, _reasons, _changeset, _changes} =
               Groups.insert_accounts(group, [account_user.id, account_user.id])

      assert Enum.empty?(Groups.get_group(group.id).accounts)
    end

    test "insert_instances/2 with valid instance ids add instances" do
      %{instance: instance} = instance_fixture()
      %{instance: instance2} = instance_fixture()

      group = fixture(:group)

      assert {:ok, _} = Groups.insert_instances(group, [instance.id, instance2.id])
      assert length(Groups.get_group(group.id).instances) == 2
    end

    test "insert_instances/2 with invalid instance ids returns error" do
      %{instance: instance} = instance_fixture()

      group = fixture(:group)

      assert {:error, _failed_operation, _failed_value, _changes_so_far} =
               Groups.insert_instances(group, [instance.id * 2])

      assert Enum.empty?(Groups.get_group(group.id).instances)
    end

    test "insert_instances/2 with same instance twice at the same time returns error" do
      %{instance: instance} = instance_fixture()

      group = fixture(:group)

      assert {:error, _reasons, _changeset, _changes} = Groups.insert_instances(group, [instance.id, instance.id])
      assert Enum.empty?(Groups.get_group(group.id).instances)
    end

    test "insert_instances/2 with same instance twice returns error" do
      %{instance: instance} = instance_fixture()

      group = fixture(:group)

      assert {:ok, _} = Groups.insert_instances(group, [instance.id])
      assert {:error, _reasons, _changeset, _changes} = Groups.insert_instances(group, [instance.id])
      assert length(Groups.get_group(group.id).instances) == 1
    end

    test "create group, add accounts and instances" do
      account_user = fixture(:user)
      account_admin = fixture(:admin)

      %{instance: instance} = instance_fixture()

      group = fixture(:group)

      {:ok, _} = Groups.insert_accounts(group, [account_user.id, account_admin.id])
      {:ok, _} = Groups.insert_instances(group, [instance.id])

      grp = Groups.get_group(group.id)

      assert length(grp.instances) == 1
      assert [_instance] = grp.instances
      assert length(grp.accounts) == 2
      [id1, id2] = [account_user.id, account_admin.id]
      assert [^id1, ^id2] = grp.accounts |> Enum.map(& &1.id)
    end

    test "create_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Groups.create_group(@invalid_attrs)
    end

    test "update_group/2 with valid data updates the group" do
      group = fixture(:group)
      assert {:ok, %Group{} = group} = Groups.update_group(group, @update_attrs)
      assert group.name == "some updated name"
    end

    test "update_group/2 with admin as name returns error" do
      group = fixture(:group)
      assert {:error, _error} = Groups.update_group(group, %{name: "admin"})
    end

    test "update_group/2 with blog-writer as name returns error" do
      group = fixture(:group)
      blog_group_name = Application.get_env(:rc, RC.Groups) |> Keyword.get(:blog_group_name)
      assert {:error, _error} = Groups.update_group(group, %{name: blog_group_name})
    end

    test "delete_group/1 deletes the group" do
      group = fixture(:group)
      assert {:ok, %Group{}} = Groups.delete_group(group)
      assert RC.Repo.all(Groups.Group) == []
    end

    test "instance_access?/2 return true if user in group" do
      account_user = fixture(:user)
      account_admin = fixture(:admin)

      %{instance: instance} = instance_fixture()

      group = fixture(:group)

      {:ok, _group_with_accounts} = Groups.insert_accounts(group, [account_user.id, account_admin.id])
      {:ok, _group_with_instances} = Groups.insert_instances(group, [instance.id])

      assert Groups.instance_access?(account_user.id, instance.id) == true
    end

    test "instance_access?/2 return false if user not in group" do
      account_user = fixture(:user)
      account_admin = fixture(:admin)

      %{instance: instance} = instance_fixture()

      group = fixture(:group)

      {:ok, _group_with_accounts} = Groups.insert_accounts(group, [account_admin.id])
      {:ok, _group_with_instances} = Groups.insert_instances(group, [instance.id])

      assert Groups.instance_access?(account_user.id, instance.id) == false
    end

    test "instance_access?/2 return false if instance not in group" do
      account_user = fixture(:user)
      account_admin = fixture(:admin)

      %{instance: instance} = instance_fixture()

      group = fixture(:group)

      {:ok, _group_with_accounts} = Groups.insert_accounts(group, [account_user.id, account_admin.id])

      assert Groups.instance_access?(account_user.id, instance.id) == false
    end

    test "instance_in_group?/1 return true if instance belongs to a group" do
      account_admin = fixture(:admin)

      %{instance: instance} = instance_fixture()

      group = fixture(:group)

      {:ok, _group_with_accounts} = Groups.insert_accounts(group, [account_admin.id])
      {:ok, _group_with_instances} = Groups.insert_instances(group, [instance.id])

      assert Groups.instance_in_group?(instance.id) == true
    end

    test "instance_in_group?/1 return false if instance does not belong to a group" do
      %{instance: instance} = instance_fixture()

      assert Groups.instance_in_group?(instance.id) == false
    end
  end
end
