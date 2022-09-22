defmodule Data.Game.BonusPipelineOut.Content do
  def data do
    [
      %Data.Game.BonusPipelineOut{
        key: :sys_production,
        to: :stellar_system,
        to_key: :production,
        icon: "resource/production"
      },
      %Data.Game.BonusPipelineOut{
        key: :sys_technology,
        to: :stellar_system,
        to_key: :technology,
        icon: "resource/technology"
      },
      %Data.Game.BonusPipelineOut{
        key: :sys_ideology,
        to: :stellar_system,
        to_key: :ideology,
        icon: "resource/ideology"
      },
      %Data.Game.BonusPipelineOut{
        key: :sys_credit,
        to: :stellar_system,
        to_key: :credit,
        icon: "resource/credit"
      },
      %Data.Game.BonusPipelineOut{
        key: :sys_habitation,
        to: :stellar_system,
        to_key: :habitation,
        icon: "resource/habitation"
      },
      %Data.Game.BonusPipelineOut{
        key: :sys_happiness,
        to: :stellar_system,
        to_key: :happiness,
        icon: "resource/happiness"
      },
      %Data.Game.BonusPipelineOut{
        key: :sys_mobility,
        to: :stellar_system,
        to_key: :mobility,
        icon: "resource/mobility"
      },
      %Data.Game.BonusPipelineOut{
        key: :sys_ci,
        to: :stellar_system,
        to_key: :counter_intelligence,
        icon: "resource/counter_intelligence"
      },
      %Data.Game.BonusPipelineOut{
        key: :sys_defense,
        to: :stellar_system,
        to_key: :defense,
        icon: "resource/defense"
      },
      %Data.Game.BonusPipelineOut{
        key: :sys_remove_contact,
        to: :stellar_system,
        to_key: :remove_contact,
        icon: "resource/remove_contact"
      },
      %Data.Game.BonusPipelineOut{
        key: :sys_radar,
        to: :stellar_system,
        to_key: :radar,
        icon: "resource/radar"
      },
      %Data.Game.BonusPipelineOut{
        key: :sys_fighter_lvl,
        to: :stellar_system,
        to_key: :fighter_lvl,
        icon: "resource/fighter_lvl"
      },
      %Data.Game.BonusPipelineOut{
        key: :sys_corvette_lvl,
        to: :stellar_system,
        to_key: :corvette_lvl,
        icon: "resource/corvette_lvl"
      },
      %Data.Game.BonusPipelineOut{
        key: :sys_frigate_lvl,
        to: :stellar_system,
        to_key: :frigate_lvl,
        icon: "resource/frigate_lvl"
      },
      %Data.Game.BonusPipelineOut{
        key: :sys_capital_lvl,
        to: :stellar_system,
        to_key: :capital_lvl,
        icon: "resource/capital_lvl"
      },
      %Data.Game.BonusPipelineOut{
        key: :player_system,
        to: :player,
        to_key: :max_systems,
        icon: "resource/resource"
      },
      %Data.Game.BonusPipelineOut{
        key: :player_dominion,
        to: :player,
        to_key: :max_dominions,
        icon: "resource/resource"
      },
      %Data.Game.BonusPipelineOut{
        key: :player_admiral,
        to: :player,
        to_key: :max_admirals,
        icon: "agent/admiral"
      },
      %Data.Game.BonusPipelineOut{
        key: :player_spy,
        to: :player,
        to_key: :max_spies,
        icon: "agent/spy"
      },
      %Data.Game.BonusPipelineOut{
        key: :player_speaker,
        to: :player,
        to_key: :max_speakers,
        icon: "agent/speaker"
      },
      %Data.Game.BonusPipelineOut{
        key: :player_credit,
        to: :player,
        to_key: :credit,
        icon: "resource/credit"
      },
      %Data.Game.BonusPipelineOut{
        key: :player_technology,
        to: :player,
        to_key: :technology,
        icon: "resource/technology"
      },
      %Data.Game.BonusPipelineOut{
        key: :player_ideology,
        to: :player,
        to_key: :ideology,
        icon: "resource/ideology"
      },
      %Data.Game.BonusPipelineOut{
        key: :character_experience,
        to: :character,
        to_key: :experience,
        icon: "resource/resource"
      },
      %Data.Game.BonusPipelineOut{
        key: :army_maintenance,
        to: :army,
        to_key: :maintenance,
        icon: "resource/credit"
      },
      %Data.Game.BonusPipelineOut{
        key: :army_repair,
        to: :army,
        to_key: :repair_coef,
        icon: "ship/repair"
      },
      %Data.Game.BonusPipelineOut{
        key: :army_invasion,
        to: :army,
        to_key: :invasion_coef,
        icon: "ship/invasion"
      },
      %Data.Game.BonusPipelineOut{
        key: :army_raid,
        to: :army,
        to_key: :raid_coef,
        icon: "ship/raid"
      },
      %Data.Game.BonusPipelineOut{
        key: :spy_cover,
        to: :spy,
        to_key: :cover,
        icon: "resource/resource"
      },
      %Data.Game.BonusPipelineOut{
        key: :spy_infiltrate,
        to: :spy,
        to_key: :infiltrate_coef,
        icon: "action/infiltrate_alt"
      },
      %Data.Game.BonusPipelineOut{
        key: :spy_sabotage,
        to: :spy,
        to_key: :sabotage_coef,
        icon: "action/sabotage_alt"
      },
      %Data.Game.BonusPipelineOut{
        key: :spy_assassination,
        to: :spy,
        to_key: :assassination_coef,
        icon: "action/assassination_alt"
      },
      %Data.Game.BonusPipelineOut{
        key: :speaker_make_dominion,
        to: :speaker,
        to_key: :make_dominion_coef,
        icon: "action/make_dominion_alt"
      },
      %Data.Game.BonusPipelineOut{
        key: :speaker_encourage_hate,
        to: :speaker,
        to_key: :encourage_hate_coef,
        icon: "action/encourage_hate_alt"
      },
      %Data.Game.BonusPipelineOut{
        key: :speaker_conversion,
        to: :speaker,
        to_key: :conversion_coef,
        icon: "action/conversion_alt"
      },
      %Data.Game.BonusPipelineOut{
        key: :dominion_rate,
        to: :player,
        to_key: :dominion_rate,
        icon: "resource/resource"
      }
    ]
  end
end
