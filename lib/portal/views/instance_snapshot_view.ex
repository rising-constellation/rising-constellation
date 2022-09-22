defmodule Portal.InstanceSnapshotView do
  use Portal, :view
  alias Portal.InstanceSnapshotView

  def render("index.json", %{instance_snapshots: instance_snapshots}) do
    render_many(instance_snapshots, InstanceSnapshotView, "instance_snapshot.json")
  end

  def render("show.json", %{instance_snapshot: instance_snapshot}) do
    render_one(instance_snapshot, InstanceSnapshotView, "instance_snapshot.json")
  end

  def render("instance_snapshot.json", %{instance_snapshot: instance_snapshot}) do
    %{
      id: instance_snapshot.id,
      date: instance_snapshot.inserted_at,
      name: instance_snapshot.name,
      size: instance_snapshot.size
    }
  end
end
