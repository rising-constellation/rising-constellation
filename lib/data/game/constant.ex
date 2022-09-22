defmodule Data.Game.Constant do
  use TypedStruct
  use Util.MakeEnumerable

  def jason(), do: []

  typedstruct enforce: true do
    field(:key, atom())

    # system related constants
    field(:system_starting_population, float())
    field(:system_capital_base_production, integer())
    field(:system_base_production, integer())
    field(:system_base_happiness, integer())
    field(:system_base_defense, float())
    field(:system_population_negative_happiness_factor, float())
    field(:system_population_taxes_factor, float())
    field(:system_mobility_taxes_factor, float())
    field(:system_base_growth, float())
    field(:system_raid_potential_growth, float())
    field(:system_base_radar_size, integer())
    field(:system_neutral_ratio, float())
    field(:happiness_penalty_reduction_factor, float())

    # building related constants
    field(:building_repairs_factor, float())

    # player related constants
    field(:player_starting_credit, integer())
    field(:player_starting_technology, integer())
    field(:player_starting_ideology, integer())
    field(:player_stats_interval, integer())

    # patents and doctrines related constants
    field(:initial_policy_slot_cost, integer())
    field(:policy_slot_maximum_cost, integer())
    field(:initial_update_policies_cooldown, integer())
    field(:update_policies_cooldown_factor, integer())
    field(:patent_level_price_increase, float())
    field(:doctrine_level_price_increase, float())

    # character_market related constants
    field(:market_cooldown_duration, integer())

    # market related constants
    field(:market_taxe, float())

    # transform related constant
    field(:transform_initial_cost, integer())
    field(:transform_additional_cost, integer())
    field(:abandonment_cost, integer())

    # characters related constants
    field(:max_character_in_deck, integer())
    field(:character_deck_cooldown, integer())
    field(:character_level_wages, integer())
    field(:character_base_action_xp, integer())
    field(:character_passive_xp_gain, float())
    field(:drop_explorer_xp, integer())
    field(:character_movement_factor, integer())

    # army related constants
    field(:army_tile_count, integer())
    field(:army_unit_base_morale, integer())
    field(:army_unit_morale_per_level, integer())
    field(:unit_initial_level, integer())
    field(:unit_level_growth, integer())
    field(:colonization_time, integer())
    field(:fleeing_chance, float())
    field(:raid_potential_impact, integer())
    field(:conquest_time, integer())
    field(:raid_time, integer())
    field(:loot_time, integer())

    # spy related constants
    field(:infiltration_time, integer())
    field(:cover_threshold, integer())

    # speaker related constants
    field(:make_dominion_time, integer())
    field(:encourage_hate_time, integer())
  end

  def specs do
    "Elixir." <> module = Atom.to_string(__MODULE__)
    module = "#{module}.Content"

    [
      %{
        metadata: [speed: :fast, mode: :dev],
        content_name: "constant-fast-dev",
        module: module <> ".Fast.Dev",
        sources: nil
      },
      %{
        metadata: [speed: :fast],
        content_name: "constant-fast",
        module: module <> ".Fast",
        sources: nil
      },
      %{
        metadata: [speed: :medium, mode: :dev],
        content_name: "constant-fast-dev",
        module: module <> ".Fast.Dev",
        sources: nil
      },
      %{
        metadata: [speed: :medium],
        content_name: "constant-medium",
        module: module <> ".Medium",
        sources: nil
      },
      %{
        metadata: [speed: :slow, mode: :dev],
        content_name: "constant-slow-dev",
        module: module <> ".Slow.Dev",
        sources: nil
      },
      %{
        metadata: [speed: :slow],
        content_name: "constant-slow",
        module: module <> ".Slow",
        sources: nil
      }
    ]
  end
end
