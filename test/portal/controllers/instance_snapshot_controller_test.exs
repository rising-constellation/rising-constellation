defmodule Portal.InstanceSnapshotControllerTest do
  use Portal.APIConnCase, async: true
  import RC.Fixtures
  import RC.ScenarioFixtures

  alias RC.InstanceSnapshots

  @create_attrs %{
    name: "my-snapshot-filename",
    size: 42
  }

  def insert_snapshot(_) do
    %{instance: instance} = instance_fixture()

    {:ok, instance_snapshot} =
      InstanceSnapshots.insert(
        @create_attrs
        |> Map.put(:instance_id, instance.id)
      )

    %{instance_snapshot: instance_snapshot, instance: instance}
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_account_admin]
    setup [:insert_snapshot]

    test "lists all instance_snapshots for a given instance", %{
      conn: conn,
      account: account,
      instance_snapshot: instance_snapshot,
      instance: instance
    } do
      conn =
        conn
        |> login(account)
        |> get(Routes.instance_snapshot_path(conn, :index, instance.id))

      [h | t] = json_response(conn, 200)

      assert h["id"] == instance_snapshot.id
      assert h["name"] == "my-snapshot-filename"
      assert h["size"] == 42
      assert t == []
    end

    test "returns empty list if no snapshot yet", %{
      conn: conn,
      account: account,
      instance: instance
    } do
      conn =
        conn
        |> login(account)
        |> get(Routes.instance_snapshot_path(conn, :index, instance.id + 100))

      assert json_response(conn, 200) == []
    end
  end
end
