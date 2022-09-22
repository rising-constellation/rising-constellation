defmodule Instance.Galaxy.Sector do
  use TypedStruct
  use Util.MakeEnumerable

  alias Instance.Galaxy

  def jason(), do: [except: [:area, :starter?]]

  typedstruct enforce: true do
    field(:id, integer())
    field(:name, String.t())
    field(:centroid, [float()])
    field(:area, float())
    field(:points, [])
    field(:adjacent, [integer()])
    field(:owner, atom() | nil)
    field(:starter?, boolean())
    field(:victory_points, integer())
    field(:division, [])
  end

  def new(sector, systems) do
    owner =
      if sector["faction"] != nil,
        do: String.to_existing_atom(sector["faction"]),
        else: nil

    # Indique si le secteur est un secteur de départ de faction
    # tant que la propriété du secteur n'a pas changé, la règle
    # du minimum ne s'applique pas.
    starter? = sector["faction"] != nil

    {_, sector, _} =
      %Galaxy.Sector{
        id: sector["key"],
        name: sector["name"],
        centroid: sector["centroid"],
        area: sector["area"],
        points: sector["points"],
        adjacent: [],
        owner: owner,
        starter?: starter?,
        victory_points: sector["victory_points"],
        division: []
      }
      |> update_owner(systems)

    sector
  end

  def update_owner(sector, systems) do
    old_sector = sector

    # sorted list of faction and corresponding points like
    # [%{faction: :ark, points: 2}, ...]
    factions_by_points =
      systems
      |> Enum.filter(fn system -> system.sector_id == sector.id and system.class != nil end)
      |> Enum.group_by(fn system -> system.faction end)
      |> Enum.map(fn {faction, systems} -> %{faction: faction, points: length(systems)} end)
      |> Enum.sort_by(fn faction -> faction.points end, fn a, b -> a > b end)

    sector = %{sector | division: factions_by_points}
    current_owner = Enum.find(factions_by_points, fn x -> x.faction == sector.owner end)

    # current owner might not be in the sector anymore, so we have make sure it is a map
    current_owner =
      if is_nil(current_owner),
        do: %{faction: sector.owner, points: 0},
        else: current_owner

    # if sector has starter?, dont take nil points in count
    factions_by_points =
      if sector.starter?,
        do: Enum.filter(factions_by_points, fn %{faction: faction} -> faction != nil end),
        else: factions_by_points

    # get new owner, it might be nil
    new_owner =
      case factions_by_points do
        [] ->
          sector.owner

        [new_owner | _] ->
          # select new owner
          cond do
            new_owner.points > current_owner.points -> new_owner.faction
            true -> sector.owner
          end
      end

    if new_owner == sector.owner,
      do: {:unchanged, sector, old_sector},
      else: {:changed, %{sector | owner: new_owner, starter?: false}, old_sector}
  end
end
