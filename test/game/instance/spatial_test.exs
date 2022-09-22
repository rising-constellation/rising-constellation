defmodule SpatialTest do
  use ExUnit.Case, async: true
  alias Spatial
  alias Spatial.Disk
  alias Spatial.Position

  doctest Spatial, import: true

  test "in_disk/2" do
    ddrt = "in_disk"
    {:ok, pid} = DDRT.start_link(name: Spatial.get_name(ddrt))

    a_pos = %Position{x: 5, y: 5}
    a_bbox = Spatial.bbox_from_position(a_pos)
    Spatial.s_upsert("a", a_bbox, ddrt)

    b_pos = %Position{x: 8, y: 8}
    b_bbox = Spatial.bbox_from_position(b_pos)
    Spatial.s_upsert("b", b_bbox, ddrt)

    c_pos = %Position{x: 0, y: 100}
    c_bbox = Spatial.bbox_from_position(c_pos)
    Spatial.s_upsert("c", c_bbox, ddrt)

    d_pos = %Position{x: 0, y: 10 - 0.001}
    d_bbox = Spatial.bbox_from_position(d_pos)
    Spatial.s_upsert("d", d_bbox, ddrt)

    disk = %Disk{x: 0, y: 0, radius: 10}
    nearby = Spatial.nearby(disk, ddrt) |> Enum.map(fn {_disk, name} -> name end)
    assert length(nearby) == 3
    assert Enum.member?(nearby, "a")
    assert Enum.member?(nearby, "b")
    assert Enum.member?(nearby, "d")

    assert Position.in_disk(a_pos, disk) == true
    assert Position.in_disk(b_pos, disk) == false
    assert Position.in_disk(c_pos, disk) == false
    assert Position.in_disk(d_pos, disk) == true

    Supervisor.stop(pid)
  end
end
