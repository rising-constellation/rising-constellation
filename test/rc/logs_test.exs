defmodule RC.LogsTest do
  use RC.DataCase, async: true

  alias RC.Logs
  alias RC.Accounts

  describe "logs" do
    alias RC.Logs.Log

    @valid_attrs %{action: :login}
    @update_attrs %{action: :update}
    @invalid_attrs %{action: 1}

    @create_attrs_admin %{
      email: "some@email2",
      hashed_password: "some hashed_password",
      password: "some password",
      name: "some name2",
      role: :admin,
      status: :active
    }

    def log_fixture(attrs \\ %{}) do
      {:ok, account} = Accounts.create_account(@create_attrs_admin)

      {:ok, log} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Logs.create_log(account)

      log
    end

    test "list_logs/0 returns all logs" do
      log_fixture()
      assert Logs.list_logs().total_entries == 1
    end

    test "get_log!/1 returns the log with given id" do
      log = log_fixture()
      assert Logs.get_log!(log.id) == log |> Repo.preload(:account)
    end

    test "create_log/1 with valid data creates a log" do
      {:ok, account} = Accounts.create_account(@create_attrs_admin)
      assert {:ok, %Log{} = log} = Logs.create_log(@valid_attrs, account)
      assert log.action == :login
    end

    test "create_log/1 with invalid data returns error changeset" do
      {:ok, account} = Accounts.create_account(@create_attrs_admin)
      assert {:error, %Ecto.Changeset{}} = Logs.create_log(@invalid_attrs, account)
    end

    test "update_log/2 with valid data updates the log" do
      log = log_fixture()
      assert {:ok, %Log{} = log} = Logs.update_log(log, @update_attrs)
      assert log.action == :update
    end

    test "update_log/2 with invalid data returns error changeset" do
      log = log_fixture()
      assert {:error, %Ecto.Changeset{}} = Logs.update_log(log, @invalid_attrs)
      assert log |> Repo.preload(:account) == Logs.get_log!(log.id)
    end

    test "delete_log/1 deletes the log" do
      log = log_fixture()
      assert {:ok, %Log{}} = Logs.delete_log(log)
      assert_raise Ecto.NoResultsError, fn -> Logs.get_log!(log.id) end
    end

    test "change_log/1 returns a log changeset" do
      log = log_fixture()
      assert %Ecto.Changeset{} = Logs.change_log(log)
    end
  end
end
