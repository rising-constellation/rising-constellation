defmodule Galaxy.SectorTest do
  use ExUnit.Case, async: true
  alias Instance.Galaxy.Sector

  test "update_owner/2 rules" do
    systems = [
      %{id: 1, faction: :ark, sector_id: 1},
      %{id: 2, faction: nil, sector_id: 2},
      %{id: 3, faction: :ark, sector_id: 2},
      %{id: 4, faction: :myrmezir, sector_id: 2},
      %{id: 5, faction: nil, sector_id: 2},
      %{id: 6, faction: :ark, sector_id: 2}
    ]

    sector1 = %{id: 2, starter?: true, owner: :ark}
    sector2 = %{id: 2, starter?: false, owner: :ark}
    sector3 = %{id: 2, starter?: true, owner: :myrmezir}
    sector4 = %{id: 2, starter?: true, owner: :syn}
    sector5 = %{id: 2, starter?: true, owner: nil}
    sector6 = %{id: 2, starter?: false, owner: nil}

    assert {:unchanged, %{owner: :ark}} = Sector.update_owner(sector1, systems)
    assert {:changed, %{owner: nil}} = Sector.update_owner(sector2, systems)
    assert {:changed, %{owner: :ark}} = Sector.update_owner(sector3, systems)
    assert {:changed, %{owner: :ark}} = Sector.update_owner(sector4, systems)
    assert {:changed, %{owner: :ark}} = Sector.update_owner(sector5, systems)
    assert {:unchanged, %{owner: nil}} = Sector.update_owner(sector6, systems)

    systems = [
      %{id: 1, faction: :ark, sector_id: 2},
      %{id: 2, faction: nil, sector_id: 2},
      %{id: 3, faction: :ark, sector_id: 2},
      %{id: 4, faction: :myrmezir, sector_id: 2},
      %{id: 5, faction: nil, sector_id: 2},
      %{id: 6, faction: :myrmezir, sector_id: 2}
    ]

    assert {:unchanged, %{owner: :ark}} = Sector.update_owner(sector1, systems)
    assert {:changed, %{owner: nil}} = Sector.update_owner(sector2, systems)
    assert {:unchanged, %{owner: :myrmezir}} = Sector.update_owner(sector3, systems)
    assert {:changed, %{owner: :myrmezir}} = Sector.update_owner(sector4, systems)
    assert {:changed, %{owner: :myrmezir}} = Sector.update_owner(sector5, systems)
    assert {:unchanged, %{owner: nil}} = Sector.update_owner(sector6, systems)
  end

  test "update_owner/2 does not crash when abadonning the last system of a sector" do
    # ark has zero system in sector_id = 2
    systems = [
      %{id: 1, faction: :ark, sector_id: 1},
      %{id: 2, faction: nil, sector_id: 1},
      %{id: 3, faction: :ark, sector_id: 1}
    ]

    # updating sector 2, which belongs to ark although they have no system in it, should work:
    assert {:changed, %{owner: nil}} = Sector.update_owner(%{id: 2, starter?: false, owner: :ark}, systems)
    assert {:changed, %{owner: nil}} = Sector.update_owner(%{id: 2, starter?: true, owner: :ark}, systems)
  end
end
