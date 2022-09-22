defmodule Data.Game.Ship do
  use TypedStruct
  use Util.MakeEnumerable

  def jason(), do: [except: [:hide_patent?]]

  typedstruct enforce: true do
    field(:key, atom())
    field(:class, atom())
    field(:model, atom())
    field(:illustration, String.t())
    field(:credit_cost, integer())
    field(:technology_cost, integer())
    field(:production, integer())
    field(:maintenance_cost, integer())
    field(:patent, atom())
    field(:hide_patent?, boolean())
    field(:shipyard, atom())
    field(:merge_to, atom() | nil)
    field(:unit_count, integer())
    field(:unit_pattern, [integer()])
    field(:unit_hull, integer())
    field(:unit_handling, integer())
    field(:unit_shield, integer())
    field(:unit_interception, integer())
    field(:unit_energy_strikes, [integer()])
    field(:unit_explosive_strikes, [integer()])
    field(:unit_repair_coef, float())
    field(:unit_invasion_coef, float())
    field(:unit_raid_coef, float())
    field(:weight, integer())
  end

  def specs do
    "Elixir." <> module = Atom.to_string(__MODULE__)
    module = "#{module}.Content"

    [
      %{
        metadata: [speed: :fast],
        content_name: "ship-fast",
        module: module <> ".Fast",
        sources: {"1QFhTWcat_IBQ49cpayBZLja1SsWWxxBNGYsf7tNrhWE", "ship"}
      },
      %{
        metadata: [speed: :medium],
        content_name: "ship-medium",
        module: module <> ".Medium",
        sources: {"1npyGc-dqkiUWOvXOxcbURJ6YxQNcD71uJetmEbvYRzI", "ship"}
      },
      %{
        metadata: [speed: :slow],
        content_name: "ship-slow",
        module: module <> ".Slow",
        sources: {"1vIR5EilO5e8pqOTJx6rsJbjr2tiib2FrGtmLG1hvGK0", "ship"}
      }
    ]
  end

  def csv_to_struct(_header, data, _metadata) do
    Enum.map(data, fn line ->
      [
        key,
        _name,
        class,
        model,
        credit_cost,
        technology_cost,
        production,
        maintenance_cost,
        patent,
        shipyard,
        merge_to,
        unit_count,
        unit_pattern,
        unit_hull,
        unit_handling,
        unit_shield,
        unit_interception,
        unit_energy_strikes,
        unit_explosive_strikes,
        unit_repair_coef,
        unit_invasion_coef,
        unit_raid_coef,
        weight | _rest
      ] = line

      {patent, flag} = Data.Util.parse_atom_flag(patent)
      hide_patent? = flag == "hidden"

      %Data.Game.Ship{
        key: Data.Util.parse_atom(key),
        class: Data.Util.parse_atom(class),
        model: Data.Util.parse_atom(model),
        illustration: "#{Data.Util.parse_atom(model)}.jpg",
        credit_cost: Data.Util.parse_int(credit_cost),
        technology_cost: Data.Util.parse_int(technology_cost),
        production: Data.Util.parse_int(production),
        maintenance_cost: Data.Util.parse_int(maintenance_cost),
        patent: patent,
        hide_patent?: hide_patent?,
        shipyard: Data.Util.parse_atom(shipyard),
        merge_to: Data.Util.parse_atom(merge_to),
        unit_count: Data.Util.parse_int(unit_count),
        unit_pattern: Data.Util.parse_int_list(unit_pattern),
        unit_hull: Data.Util.parse_int(unit_hull),
        unit_handling: Data.Util.parse_int(unit_handling),
        unit_shield: Data.Util.parse_int(unit_shield),
        unit_interception: Data.Util.parse_int(unit_interception),
        unit_energy_strikes: Data.Util.parse_int_list(unit_energy_strikes),
        unit_explosive_strikes: Data.Util.parse_int_list(unit_explosive_strikes),
        unit_repair_coef: Data.Util.parse_number(unit_repair_coef),
        unit_invasion_coef: Data.Util.parse_number(unit_invasion_coef),
        unit_raid_coef: Data.Util.parse_number(unit_raid_coef),
        weight: Data.Util.parse_int(weight)
      }
    end)
  end
end
