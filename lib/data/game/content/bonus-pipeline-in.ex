defmodule Data.Game.BonusPipelineIn.Content do
  def data do
    [
      %Data.Game.BonusPipelineIn{
        from: :none,
        from_key: nil,
        icon: nil,
        key: :direct,
        order: 10
      },
      %Data.Game.BonusPipelineIn{
        from: :speaker,
        from_key: :conversion_coef,
        icon: "action/conversion_alt",
        key: :speaker_conversion,
        order: 10
      },
      %Data.Game.BonusPipelineIn{
        from: :speaker,
        from_key: :encourage_hate_coef,
        icon: "action/encourage_hate_alt",
        key: :speaker_encourage_hate,
        order: 10
      },
      %Data.Game.BonusPipelineIn{
        from: :speaker,
        from_key: :make_dominion_coef,
        icon: "action/make_dominion_alt",
        key: :speaker_make_dominion,
        order: 10
      },
      %Data.Game.BonusPipelineIn{
        from: :spy,
        from_key: :assassination_coef,
        icon: "action/assassination_alt",
        key: :spy_assassination,
        order: 10
      },
      %Data.Game.BonusPipelineIn{
        from: :spy,
        from_key: :sabotage_coef,
        icon: "action/sabotage_alt",
        key: :spy_sabotage,
        order: 10
      },
      %Data.Game.BonusPipelineIn{
        from: :spy,
        from_key: :infiltrate_coef,
        icon: "action/infiltrate_alt",
        key: :spy_infiltrate,
        order: 10
      },
      %Data.Game.BonusPipelineIn{
        from: :spy,
        from_key: :cover,
        icon: "resource/resource",
        key: :spy_cover,
        order: 10
      },
      %Data.Game.BonusPipelineIn{
        from: :army,
        from_key: :raid_coef,
        icon: "ship/raid",
        key: :army_raid,
        order: 10
      },
      %Data.Game.BonusPipelineIn{
        from: :army,
        from_key: :invasion_coef,
        icon: "ship/invasion",
        key: :army_invasion,
        order: 10
      },
      %Data.Game.BonusPipelineIn{
        from: :army,
        from_key: :repair_coef,
        icon: "ship/repair",
        key: :army_repair,
        order: 10
      },
      %Data.Game.BonusPipelineIn{
        from: :army,
        from_key: :maintenance,
        icon: "resource/credit",
        key: :army_maintenance,
        order: 10
      },
      %Data.Game.BonusPipelineIn{
        from: :player,
        from_key: :dominion_rate,
        icon: "resource/resource",
        key: :dominion_rate,
        order: 10
      },
      %Data.Game.BonusPipelineIn{
        from: :stellar_system,
        from_key: :capital_lvl,
        icon: "resource/capital_lvl",
        key: :sys_capital_lvl,
        order: 20
      },
      %Data.Game.BonusPipelineIn{
        from: :stellar_system,
        from_key: :frigate_lvl,
        icon: "resource/frigate_lvl",
        key: :sys_frigate_lvl,
        order: 20
      },
      %Data.Game.BonusPipelineIn{
        from: :stellar_system,
        from_key: :corvette_lvl,
        icon: "resource/corvette_lvl",
        key: :sys_corvette_lvl,
        order: 20
      },
      %Data.Game.BonusPipelineIn{
        from: :stellar_system,
        from_key: :fighter_lvl,
        icon: "resource/fighter_lvl",
        key: :sys_fighter_lvl,
        order: 20
      },
      %Data.Game.BonusPipelineIn{
        from: :stellar_system,
        from_key: :happiness,
        icon: "resource/happiness",
        key: :sys_happiness,
        order: 20
      },
      %Data.Game.BonusPipelineIn{
        from: :stellar_body,
        from_key: :population,
        icon: "stellar_body/population",
        key: :body_pop,
        order: 20
      },
      %Data.Game.BonusPipelineIn{
        from: :stellar_body,
        from_key: :activity_factor,
        icon: "stellar_body/activity_factor",
        key: :body_act,
        order: 20
      },
      %Data.Game.BonusPipelineIn{
        from: :stellar_body,
        from_key: :technological_factor,
        icon: "stellar_body/technological_factor",
        key: :body_tec,
        order: 20
      },
      %Data.Game.BonusPipelineIn{
        from: :stellar_body,
        from_key: :industrial_factor,
        icon: "stellar_body/industrial_factor",
        key: :body_ind,
        order: 20
      },
      %Data.Game.BonusPipelineIn{
        from: :stellar_system,
        from_key: :defense,
        icon: "resource/defense",
        key: :sys_defense,
        order: 30
      },
      %Data.Game.BonusPipelineIn{
        from: :stellar_system,
        from_key: :mobility,
        icon: "resource/mobility",
        key: :sys_mobility,
        order: 30
      },
      %Data.Game.BonusPipelineIn{
        from: :stellar_system,
        from_key: :workforce,
        icon: "resource/population",
        key: :sys_pop,
        order: 30
      },
      %Data.Game.BonusPipelineIn{
        from: :stellar_system,
        from_key: :remove_contact,
        icon: "resource/remove_contact",
        key: :sys_remove_contact,
        order: 40
      },
      %Data.Game.BonusPipelineIn{
        from: :stellar_system,
        from_key: :counter_intelligence,
        icon: "resource/counter_intelligence",
        key: :sys_ci,
        order: 50
      },
      %Data.Game.BonusPipelineIn{
        from: :stellar_system,
        from_key: :production,
        icon: "resource/production",
        key: :sys_production,
        order: 60
      },
      %Data.Game.BonusPipelineIn{
        from: :stellar_system,
        from_key: :ideology,
        icon: "resource/ideology",
        key: :sys_ideology,
        order: 60
      },
      %Data.Game.BonusPipelineIn{
        from: :stellar_system,
        from_key: :technology,
        icon: "resource/technology",
        key: :sys_technology,
        order: 60
      },
      %Data.Game.BonusPipelineIn{
        from: :stellar_system,
        from_key: :credit,
        icon: "resource/credit",
        key: :sys_credit,
        order: 60
      },
      %Data.Game.BonusPipelineIn{
        from: :player,
        from_key: :ideology,
        icon: "resource/ideology",
        key: :player_ideology,
        order: 70
      },
      %Data.Game.BonusPipelineIn{
        from: :player,
        from_key: :technology,
        icon: "resource/technology",
        key: :player_technology,
        order: 70
      },
      %Data.Game.BonusPipelineIn{
        from: :player,
        from_key: :credit,
        icon: "resource/credit",
        key: :player_credit,
        order: 70
      },
      %Data.Game.BonusPipelineIn{
        from: :none,
        from_key: nil,
        icon: nil,
        key: :direct_last,
        order: 80
      }
    ]

    # |> Enum.sort(& (&1.order < &2.order))
    # always keep this file sorted, that way we don't have to sort it everytime we access .data()
  end
end
