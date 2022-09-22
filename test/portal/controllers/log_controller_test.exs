defmodule Portal.LogControllerTest do
  use Portal.APIConnCase, async: true
  import RC.Fixtures

  alias RC.Logs

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_account_admin]

    test "lists all logs", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> get(Routes.log_path(conn, :index))

      assert conn.assigns.logs.total_entries == 0
    end
  end

  describe "index by account" do
    setup [:create_account_user]

    test "lists all logs when account id is valid", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> put(Routes.account_path(conn, :update_restricted, account), account: account_update_attrs())
        |> get(Routes.log_path(conn, :index_by_account, account.id))

      pages = conn.assigns.logs
      [log | _] = pages.entries

      assert pages.total_entries == 1
      assert log.action == :update_restricted
      assert log.account_id == account.id
      assert log.account.id == log.account_id
      assert log.account.email == account_update_attrs().email
      assert log.account.name == account_update_attrs().name
    end

    test "throw error when account id is not valid", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> put(Routes.account_path(conn, :update_restricted, account), account: account_update_attrs())
        |> get(Routes.log_path(conn, :index_by_account, account.id + 1))

      assert json_response(conn, 403) == %{"message" => "forbidden"}
    end
  end

  describe "create an account" do
    test "add log when data is valid", %{conn: conn} do
      post(conn, Routes.account_path(conn, :create), account: account_valid_user_attrs())

      pages = Logs.list_logs()
      [log | _] = pages.entries

      # assert log.action == :create_account
      assert pages.total_entries == 1
      assert log.action == :create_account
      assert log.account.email == account_valid_user_attrs().email
      assert log.account.name == account_valid_user_attrs().name
      assert log.account.role == account_valid_user_attrs().role
      assert log.account.status == account_valid_user_attrs().status
    end
  end

  describe "update account restricted" do
    setup [:create_account_user]

    test "adds log when update data is valid", %{conn: conn, account: account} do
      conn
      |> login(account)
      |> put(Routes.account_path(conn, :update_restricted, account), account: account_update_attrs())

      pages = Logs.list_logs()
      [log | _] = pages.entries

      assert pages.total_entries == 1
      assert log.action == :update_restricted
      assert log.account_id == account.id
      assert log.account.id == log.account_id
      assert log.account.email == account_update_attrs().email
      assert log.account.name == account_update_attrs().name
    end
  end

  describe "update account" do
    setup [:create_account_admin]

    test "adds log when update data is valid", %{conn: conn, account: account} do
      conn
      |> login(account)
      |> put(Routes.account_path(conn, :update, account), account: account_update_attrs())

      pages = Logs.list_logs()
      [log | _] = pages.entries

      assert log.action == :update
      assert log.account_id == account.id
      assert log.account.id == log.account_id
      assert log.account.email == account_update_attrs().email
      assert log.account.name == account_update_attrs().name
      assert log.account.role == account_update_attrs().role
      assert log.account.status == account_update_attrs().status
    end
  end
end
