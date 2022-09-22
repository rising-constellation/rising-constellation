defmodule Portal.AdminViewTest do
  use Portal.HTMLConnCase, async: true
  import RC.Fixtures

  test "requires admin auth - unauthenticated", %{conn: conn} do
    conn = get(conn, "/admin")
    assert html_response(conn, 401) =~ "unauthenticated"
  end

  test "requires admin auth - forbidden", %{conn: conn} do
    account_user = fixture(:user)

    conn =
      conn
      |> login(account_user)
      |> get("/admin")

    assert html_response(conn, 403) =~ "forbidden"
  end

  test "requires admin auth - ok", %{conn: conn} do
    account_admin = fixture(:admin)

    conn =
      conn
      |> login(account_admin)
      |> get("/admin")

    assert html_response(conn, 200) =~ ""

    {:ok, _view, _html} = live(conn)
  end
end
