defmodule Portal.InstanceSnapshotController do
  use Portal, :controller

  alias RC.InstanceSnapshots

  require Logger

  action_fallback(Portal.FallbackController)

  def save(conn, %{"iid" => iid}) do
    iid = String.to_integer(iid)

    case Instance.Manager.call(iid, :make_snapshot) do
      {:ok, instance_snapshot} ->
        conn
        |> put_status(:ok)
        |> render("show.json", instance_snapshot: instance_snapshot)

      {:error, :instance_not_found} ->
        conn
        |> put_status(404)
        |> json(%{message: :supervisor_instance_not_found})

      {:error, reason} ->
        Logger.info("#{inspect(reason)}")

        conn
        |> put_status(500)
        |> json(%{message: :general_error})
    end
  end

  def index(conn, %{"iid" => iid}) do
    instance_snapshots = InstanceSnapshots.list(iid)
    render(conn, "index.json", instance_snapshots: instance_snapshots)
  end
end
