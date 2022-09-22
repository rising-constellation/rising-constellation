defmodule Data.Game.Patent do
  use TypedStruct
  use Util.MakeEnumerable

  def jason(), do: []

  typedstruct enforce: true do
    field(:key, atom())
    field(:type, atom())
    field(:class, atom())
    field(:ancestor, atom())
    field(:unlock, [%{}])
    field(:illustration, String.t())
    field(:cost, integer())
    field(:info, atom() | nil)
  end

  def specs do
    "Elixir." <> module = Atom.to_string(__MODULE__)
    module = "#{module}.Content"

    [
      %{
        metadata: [speed: :fast],
        content_name: "patent-fast",
        module: module <> ".Fast",
        sources: {"1QFhTWcat_IBQ49cpayBZLja1SsWWxxBNGYsf7tNrhWE", "patent"}
      },
      %{
        metadata: [speed: :medium],
        content_name: "patent-medium",
        module: module <> ".Medium",
        sources: {"1npyGc-dqkiUWOvXOxcbURJ6YxQNcD71uJetmEbvYRzI", "patent"}
      },
      %{
        metadata: [speed: :slow],
        content_name: "patent-slow",
        module: module <> ".Slow",
        sources: {"1vIR5EilO5e8pqOTJx6rsJbjr2tiib2FrGtmLG1hvGK0", "patent"}
      }
    ]
  end

  def csv_to_struct(_header, data, metadata) do
    # fetch all ships and building with the same metadata
    # allowing to add "dependencies" to patents
    ships = Data.Querier.fetch_all(Data.Game.Ship, metadata)
    buildings = Data.Querier.fetch_all(Data.Game.Building, metadata)

    Enum.map(data, fn line ->
      [key, ancestor, type, class, illustration, cost, info | _rest] = line

      key = Data.Util.parse_atom(key)
      type = Data.Util.parse_atom(type)

      unlock_buildings =
        buildings
        |> Enum.flat_map(fn building ->
          building.levels
          |> Enum.filter(fn level -> not level.hide_patent? and level.patent == key end)
          |> Enum.map(fn level -> %{type: :building, key: building.key, level: level.level} end)
        end)

      unlock_ships =
        ships
        |> Enum.filter(fn ship -> not ship.hide_patent? and ship.patent == key end)
        |> Enum.map(fn ship -> %{type: :ship, key: ship.key} end)

      %Data.Game.Patent{
        key: key,
        type: type,
        class: Data.Util.parse_atom(class),
        ancestor: Data.Util.parse_atom(ancestor),
        unlock: List.flatten([unlock_buildings, unlock_ships]),
        illustration: illustration,
        cost: Data.Util.parse_int(cost),
        info: Data.Util.parse_atom(info)
      }
    end)
  end
end
