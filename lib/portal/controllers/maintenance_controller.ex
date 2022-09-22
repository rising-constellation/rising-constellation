defmodule Portal.MaintenanceController do
  use Portal, :controller

  def healthcheck(conn, _params) do
    conn
    |> put_status(200)
    |> json("ok")
  end

  def maintenance(conn, _params) do
    if RC.Maintenance.get_flag() do
      conn
      |> put_status(500)
      |> json(true)
    else
      conn
      |> put_status(200)
      |> json(0)
    end
  end

  def backend_version(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{version: RC.Maintenance.get_version()})
  end
end
