# credo:disable-for-this-file Credo.Check.Readability.LargeNumbers

defmodule Data.Game.Doctrine.Content.Slow do
  def data do
    [
      %Data.Game.Doctrine{
        ancestor: nil,
        bonus: [
          %Core.Bonus{from: :direct, to: :player_spy, type: :add, value: 2},
          %Core.Bonus{from: :direct, to: :player_admiral, type: :add, value: 2},
          %Core.Bonus{from: :direct, to: :player_speaker, type: :add, value: 2}
        ],
        class: :root,
        cost: 50,
        illustration: "agent.jpg",
        key: :agent,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :agent,
        bonus: [%Core.Bonus{from: :direct, to: :player_system, type: :add, value: 1}],
        class: :expansion,
        cost: 7000,
        illustration: "system_1.jpg",
        key: :system_1,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :system_1,
        bonus: [
          %Core.Bonus{from: :direct, to: :player_system, type: :add, value: 1},
          %Core.Bonus{from: :direct, to: :player_technology, type: :add, value: -30}
        ],
        class: :expansion,
        cost: 20000,
        illustration: "system_2.jpg",
        key: :system_2,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :system_2,
        bonus: [%Core.Bonus{from: :direct, to: :sys_mobility, type: :add, value: 20}],
        class: :expansion,
        cost: 2000,
        illustration: "mobility_1.jpg",
        key: :mobility_1,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :mobility_1,
        bonus: [
          %Core.Bonus{from: :direct, to: :player_system, type: :add, value: 2},
          %Core.Bonus{from: :player_credit, to: :player_credit, type: :mul, value: -0.04},
          %Core.Bonus{from: :direct, to: :player_technology, type: :add, value: -20},
          %Core.Bonus{from: :direct, to: :player_ideology, type: :add, value: -50}
        ],
        class: :expansion,
        cost: 60000,
        illustration: "system_3.jpg",
        key: :system_3,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :system_3,
        bonus: [
          %Core.Bonus{from: :sys_mobility, to: :sys_mobility, type: :mul, value: 0.1},
          %Core.Bonus{from: :direct, to: :player_credit, type: :add, value: -100}
        ],
        class: :expansion,
        cost: 10000,
        illustration: "mobility_2.jpg",
        key: :mobility_2,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :mobility_2,
        bonus: [
          %Core.Bonus{from: :direct, to: :player_system, type: :add, value: 3},
          %Core.Bonus{from: :player_credit, to: :player_credit, type: :mul, value: -0.08},
          %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -16},
          %Core.Bonus{from: :direct, to: :player_ideology, type: :add, value: -150}
        ],
        class: :expansion,
        cost: 200_000,
        illustration: "system_4.jpg",
        key: :system_4,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :system_2,
        bonus: [
          %Core.Bonus{from: :sys_pop, to: :sys_credit, type: :mul, value: 2},
          %Core.Bonus{from: :sys_defense, to: :sys_defense, type: :mul, value: -0.25}
        ],
        class: :expansion,
        cost: 2000,
        illustration: "credit_pop.jpg",
        key: :credit_pop,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :credit_pop,
        bonus: [
          %Core.Bonus{from: :direct, to: :player_system, type: :add, value: 1},
          %Core.Bonus{from: :direct, to: :player_dominion, type: :add, value: 2},
          %Core.Bonus{from: :player_credit, to: :player_credit, type: :mul, value: -0.03},
          %Core.Bonus{from: :direct, to: :player_ideology, type: :add, value: -50}
        ],
        class: :expansion,
        cost: 50000,
        illustration: "sys_dom_1.jpg",
        key: :sys_dom_1,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :sys_dom_1,
        bonus: [
          %Core.Bonus{from: :direct, to: :player_system, type: :add, value: 2},
          %Core.Bonus{from: :direct, to: :player_dominion, type: :add, value: 4},
          %Core.Bonus{from: :player_credit, to: :player_credit, type: :mul, value: -0.06},
          %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -8},
          %Core.Bonus{from: :direct, to: :player_technology, type: :add, value: -100}
        ],
        class: :expansion,
        cost: 180_000,
        illustration: "sys_dom_2.jpg",
        key: :sys_dom_2,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :system_1,
        bonus: [%Core.Bonus{from: :direct, to: :player_dominion, type: :add, value: 3}],
        class: :expansion,
        cost: 9000,
        illustration: "dominion_1.jpg",
        key: :dominion_1,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :dominion_1,
        bonus: [%Core.Bonus{from: :direct, to: :dominion_rate, type: :add, value: 0.2}],
        class: :expansion,
        cost: 5000,
        illustration: "dominion_rate_1.jpg",
        key: :dominion_rate_1,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :dominion_rate_1,
        bonus: [
          %Core.Bonus{from: :direct, to: :player_dominion, type: :add, value: 4},
          %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -8},
          %Core.Bonus{from: :direct, to: :dominion_rate, type: :add, value: 0.05},
          %Core.Bonus{from: :direct, to: :player_ideology, type: :add, value: -30}
        ],
        class: :expansion,
        cost: 40000,
        illustration: "dominion_2.jpg",
        key: :dominion_2,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :dominion_2,
        bonus: [%Core.Bonus{from: :direct, to: :dominion_rate, type: :add, value: 0.3}],
        class: :expansion,
        cost: 20000,
        illustration: "dominion_rate_2.jpg",
        key: :dominion_rate_2,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :dominion_rate_2,
        bonus: [
          %Core.Bonus{from: :direct, to: :player_dominion, type: :add, value: 7},
          %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -12},
          %Core.Bonus{from: :direct, to: :dominion_rate, type: :add, value: 0.05},
          %Core.Bonus{from: :direct, to: :player_ideology, type: :add, value: -90}
        ],
        class: :expansion,
        cost: 120_000,
        illustration: "dominion_3.jpg",
        key: :dominion_3,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :agent,
        bonus: [%Core.Bonus{from: :direct, to: :player_admiral, type: :add, value: 2}],
        class: :admiral,
        cost: 50,
        illustration: "admiral_1.jpg",
        key: :admiral_1,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :admiral_1,
        bonus: [
          %Core.Bonus{from: :direct, to: :army_raid, type: :add, value: 20},
          %Core.Bonus{from: :direct, to: :player_credit, type: :add, value: -50}
        ],
        class: :admiral,
        cost: 500,
        illustration: "upgrade_raid.jpg",
        key: :upgrade_raid,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :upgrade_raid,
        bonus: [%Core.Bonus{from: :direct, to: :player_admiral, type: :add, value: 4}],
        class: :admiral,
        cost: 1000,
        illustration: "admiral_2.jpg",
        key: :admiral_2,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :admiral_2,
        bonus: [
          %Core.Bonus{from: :army_maintenance, to: :army_maintenance, type: :mul, value: -0.1}
        ],
        class: :admiral,
        cost: 5000,
        illustration: "reduce_maitenance_1.jpg",
        key: :reduce_maintenance_1,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :reduce_maintenance_1,
        bonus: [
          %Core.Bonus{from: :direct, to: :player_admiral, type: :add, value: 5},
          %Core.Bonus{from: :direct, to: :player_spy, type: :add, value: 2},
          %Core.Bonus{from: :player_credit, to: :player_credit, type: :mul, value: -0.04}
        ],
        class: :admiral,
        cost: 18000,
        illustration: "admiral_3.jpg",
        key: :admiral_3,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :admiral_3,
        bonus: [%Core.Bonus{from: :army_invasion, to: :army_invasion, type: :mul, value: 0.22}],
        class: :admiral,
        cost: 80000,
        illustration: "upgrade_invasion.jpg",
        key: :upgrade_invasion,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :reduce_maintenance_1,
        bonus: [
          %Core.Bonus{from: :direct, to: :player_admiral, type: :add, value: 5},
          %Core.Bonus{from: :direct, to: :player_speaker, type: :add, value: 2},
          %Core.Bonus{from: :player_credit, to: :player_credit, type: :mul, value: -0.04}
        ],
        class: :admiral,
        cost: 18000,
        illustration: "admiral_4.jpg",
        key: :admiral_4,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :admiral_4,
        bonus: [
          %Core.Bonus{from: :army_maintenance, to: :army_maintenance, type: :mul, value: -0.18}
        ],
        class: :admiral,
        cost: 80000,
        illustration: "reduce_maintenance_2.jpg",
        key: :reduce_maintenance_2,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :admiral_2,
        bonus: [
          %Core.Bonus{from: :army_repair, to: :army_repair, type: :mul, value: 0.1},
          %Core.Bonus{from: :sys_production, to: :sys_production, type: :mul, value: 0.12}
        ],
        class: :admiral,
        cost: 2000,
        illustration: "upgrade_repair.jpg",
        key: :upgrade_repair,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :upgrade_repair,
        bonus: [
          %Core.Bonus{from: :army_repair, to: :army_repair, type: :mul, value: 0.2},
          %Core.Bonus{from: :army_invasion, to: :army_invasion, type: :mul, value: 0.08},
          %Core.Bonus{from: :army_raid, to: :army_raid, type: :mul, value: 0.1},
          %Core.Bonus{from: :player_credit, to: :player_credit, type: :mul, value: -0.08}
        ],
        class: :admiral,
        cost: 60000,
        illustration: "upgrade_fleet.jpg",
        key: :upgrade_fleet,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :admiral_1,
        bonus: [
          %Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 25},
          %Core.Bonus{from: :sys_production, to: :sys_production, type: :mul, value: -0.5}
        ],
        class: :admiral,
        cost: 500,
        illustration: "defense_1.jpg",
        key: :defense_1,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :defense_1,
        bonus: [%Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 30}],
        class: :admiral,
        cost: 3000,
        illustration: "prod_1.jpg",
        key: :prod_1,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :prod_1,
        bonus: [
          %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 50},
          %Core.Bonus{from: :sys_production, to: :sys_production, type: :mul, value: 0.1}
        ],
        class: :admiral,
        cost: 20000,
        illustration: "prod_2.jpg",
        key: :prod_2,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :prod_2,
        bonus: [
          %Core.Bonus{from: :sys_fighter_lvl, to: :sys_fighter_lvl, type: :mul, value: 0.3},
          %Core.Bonus{from: :sys_corvette_lvl, to: :sys_corvette_lvl, type: :mul, value: 0.3},
          %Core.Bonus{from: :sys_frigate_lvl, to: :sys_frigate_lvl, type: :mul, value: 0.3},
          %Core.Bonus{from: :sys_capital_lvl, to: :sys_capital_lvl, type: :mul, value: 0.3}
        ],
        class: :admiral,
        cost: 100_000,
        illustration: "upgrade_xp.jpg",
        key: :upgrade_xp,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :agent,
        bonus: [%Core.Bonus{from: :direct, to: :player_credit, type: :add, value: 100}],
        class: :spy,
        cost: 50,
        illustration: "credit_1.jpg",
        key: :credit_1,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :credit_1,
        bonus: [
          %Core.Bonus{from: :direct, to: :player_spy, type: :add, value: 4},
          %Core.Bonus{from: :direct, to: :player_credit, type: :add, value: -200}
        ],
        class: :spy,
        cost: 1000,
        illustration: "spy_1.jpg",
        key: :spy_1,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :spy_1,
        bonus: [%Core.Bonus{from: :direct, to: :spy_infiltrate, type: :add, value: 15}],
        class: :spy,
        cost: 3000,
        illustration: "infiltration.jpg",
        key: :infiltration,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :infiltration,
        bonus: [
          %Core.Bonus{from: :direct, to: :player_spy, type: :add, value: 7},
          %Core.Bonus{from: :direct, to: :player_speaker, type: :add, value: 2},
          %Core.Bonus{from: :player_technology, to: :player_technology, type: :mul, value: -0.04}
        ],
        class: :spy,
        cost: 18000,
        illustration: "spy_3.jpg",
        key: :spy_3,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :spy_3,
        bonus: [%Core.Bonus{from: :direct, to: :spy_assassination, type: :add, value: 25}],
        class: :spy,
        cost: 25000,
        illustration: "assassinate.jpg",
        key: :assassinate,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :assassinate,
        bonus: [
          %Core.Bonus{from: :direct, to: :spy_cover, type: :add, value: 0.3},
          %Core.Bonus{from: :player_ideology, to: :player_ideology, type: :mul, value: -0.05}
        ],
        class: :spy,
        cost: 90000,
        illustration: "cover.jpg",
        key: :cover,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :infiltration,
        bonus: [
          %Core.Bonus{from: :direct, to: :player_spy, type: :add, value: 7},
          %Core.Bonus{from: :direct, to: :player_admiral, type: :add, value: 2},
          %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -14}
        ],
        class: :spy,
        cost: 18000,
        illustration: "spy_4.jpg",
        key: :spy_4,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :spy_4,
        bonus: [%Core.Bonus{from: :direct, to: :spy_sabotage, type: :add, value: 40}],
        class: :spy,
        cost: 25000,
        illustration: "sabotage.jpg",
        key: :sabotage,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :sabotage,
        bonus: [
          %Core.Bonus{from: :spy_infiltrate, to: :spy_infiltrate, type: :mul, value: 0.25},
          %Core.Bonus{from: :spy_sabotage, to: :spy_sabotage, type: :mul, value: 0.15},
          %Core.Bonus{from: :spy_assassination, to: :spy_assassination, type: :mul, value: 0.15}
        ],
        class: :spy,
        cost: 80000,
        illustration: "spy_bonus.jpg",
        key: :spy_bonus,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :spy_1,
        bonus: [
          %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 30},
          %Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 20}
        ],
        class: :spy,
        cost: 5000,
        illustration: "spy_def_1.jpg",
        key: :spy_def_1,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :spy_def_1,
        bonus: [
          %Core.Bonus{from: :sys_ci, to: :sys_ci, type: :mul, value: 0.3},
          %Core.Bonus{from: :sys_remove_contact, to: :sys_remove_contact, type: :mul, value: 1},
          %Core.Bonus{from: :player_credit, to: :player_credit, type: :mul, value: 0.05}
        ],
        class: :spy,
        cost: 80000,
        illustration: "spy_def_2.jpg",
        key: :spy_def_2,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :credit_1,
        bonus: [%Core.Bonus{from: :player_credit, to: :player_credit, type: :mul, value: 0.1}],
        class: :spy,
        cost: 1000,
        illustration: "credit_perc_1.jpg",
        key: :credit_perc_1,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :credit_perc_1,
        bonus: [%Core.Bonus{from: :direct, to: :player_credit, type: :add, value: 300}],
        class: :spy,
        cost: 3000,
        illustration: "credit_2.jpg",
        key: :credit_2,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :credit_2,
        bonus: [
          %Core.Bonus{from: :player_credit, to: :player_credit, type: :mul, value: 0.15},
          %Core.Bonus{from: :direct, to: :player_spy, type: :add, value: 2}
        ],
        class: :spy,
        cost: 25000,
        illustration: "spy_2.jpg",
        key: :spy_2,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :spy_2,
        bonus: [%Core.Bonus{from: :direct, to: :player_credit, type: :add, value: 500}],
        class: :spy,
        cost: 20000,
        illustration: "credit_3.jpg",
        key: :credit_3,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :credit_3,
        bonus: [
          %Core.Bonus{from: :player_credit, to: :player_credit, type: :mul, value: 0.4},
          %Core.Bonus{from: :player_technology, to: :player_technology, type: :mul, value: -0.1},
          %Core.Bonus{from: :player_ideology, to: :player_ideology, type: :mul, value: -0.1},
          %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -24}
        ],
        class: :spy,
        cost: 100_000,
        illustration: "credit_pola_1.jpg",
        key: :credit_pola_1,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :agent,
        bonus: [
          %Core.Bonus{from: :direct, to: :player_ideology, type: :add, value: 3},
          %Core.Bonus{from: :direct, to: :player_technology, type: :add, value: 3}
        ],
        class: :speaker,
        cost: 50,
        illustration: "speaker_1.jpg",
        key: :speaker_1,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :speaker_1,
        bonus: [%Core.Bonus{from: :direct, to: :player_ideology, type: :add, value: 6}],
        class: :speaker,
        cost: 300,
        illustration: "ideo_1.jpg",
        key: :ideo_1,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :ideo_1,
        bonus: [%Core.Bonus{from: :direct, to: :player_ideology, type: :add, value: 16}],
        class: :speaker,
        cost: 3000,
        illustration: "ideo_2.jpg",
        key: :ideo_2,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :ideo_2,
        bonus: [%Core.Bonus{from: :direct, to: :player_speaker, type: :add, value: 3}],
        class: :speaker,
        cost: 3000,
        illustration: "speaker_2.jpg",
        key: :speaker_2,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :speaker_2,
        bonus: [
          %Core.Bonus{from: :direct, to: :player_speaker, type: :add, value: 6},
          %Core.Bonus{from: :direct, to: :player_admiral, type: :add, value: 2},
          %Core.Bonus{from: :player_technology, to: :player_technology, type: :mul, value: -0.04}
        ],
        class: :speaker,
        cost: 20000,
        illustration: "speaker_3.jpg",
        key: :speaker_3,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :speaker_3,
        bonus: [
          %Core.Bonus{
            from: :speaker_make_dominion,
            to: :speaker_make_dominion,
            type: :mul,
            value: 0.2
          },
          %Core.Bonus{
            from: :speaker_encourage_hate,
            to: :speaker_encourage_hate,
            type: :mul,
            value: 0.2
          }
        ],
        class: :speaker,
        cost: 80000,
        illustration: "speaker_dominion.jpg",
        key: :speaker_dominion,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :speaker_2,
        bonus: [
          %Core.Bonus{from: :direct, to: :player_speaker, type: :add, value: 6},
          %Core.Bonus{from: :direct, to: :player_spy, type: :add, value: 2},
          %Core.Bonus{from: :sys_production, to: :sys_production, type: :mul, value: -0.1}
        ],
        class: :speaker,
        cost: 20000,
        illustration: "speaker_4.jpg",
        key: :speaker_4,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :speaker_4,
        bonus: [
          %Core.Bonus{from: :direct, to: :speaker_conversion, type: :add, value: 20},
          %Core.Bonus{from: :speaker_conversion, to: :speaker_conversion, type: :mul, value: 0.1}
        ],
        class: :speaker,
        cost: 80000,
        illustration: "conversion.jpg",
        key: :conversion,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :ideo_2,
        bonus: [%Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 40}],
        class: :speaker,
        cost: 6000,
        illustration: "stab_2.jpg",
        key: :stab_2,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :stab_2,
        bonus: [
          %Core.Bonus{from: :player_ideology, to: :player_ideology, type: :mul, value: 0.15}
        ],
        class: :speaker,
        cost: 30000,
        illustration: "ideo_3.jpg",
        key: :ideo_3,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :ideo_3,
        bonus: [
          %Core.Bonus{from: :player_ideology, to: :player_ideology, type: :mul, value: 0.3},
          %Core.Bonus{from: :player_technology, to: :player_technology, type: :mul, value: -0.06},
          %Core.Bonus{from: :player_credit, to: :player_credit, type: :mul, value: -0.06}
        ],
        class: :speaker,
        cost: 100_000,
        illustration: "ideo_pola.jpg",
        key: :ideo_pola,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :speaker_1,
        bonus: [%Core.Bonus{from: :direct, to: :player_technology, type: :add, value: 6}],
        class: :speaker,
        cost: 300,
        illustration: "tech_1.jpg",
        key: :tech_1,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :tech_1,
        bonus: [
          %Core.Bonus{from: :direct, to: :player_technology, type: :add, value: 10},
          %Core.Bonus{from: :direct, to: :player_speaker, type: :add, value: 2}
        ],
        class: :speaker,
        cost: 3000,
        illustration: "tech_2.jpg",
        key: :tech_2,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :tech_2,
        bonus: [
          %Core.Bonus{from: :player_credit, to: :player_credit, type: :mul, value: 0.05},
          %Core.Bonus{from: :player_technology, to: :player_technology, type: :mul, value: 0.05},
          %Core.Bonus{from: :sys_production, to: :sys_production, type: :mul, value: 0.05}
        ],
        class: :speaker,
        cost: 4000,
        illustration: "stab_1.jpg",
        key: :stab_1,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :stab_1,
        bonus: [
          %Core.Bonus{from: :player_technology, to: :player_technology, type: :mul, value: 0.15}
        ],
        class: :speaker,
        cost: 30000,
        illustration: "tech_3.jpg",
        key: :tech_3,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :tech_3,
        bonus: [
          %Core.Bonus{from: :player_technology, to: :player_technology, type: :mul, value: 0.3},
          %Core.Bonus{from: :player_ideology, to: :player_ideology, type: :mul, value: -0.06},
          %Core.Bonus{from: :sys_production, to: :sys_production, type: :mul, value: -0.04}
        ],
        class: :speaker,
        cost: 100_000,
        illustration: "tech_pola.jpg",
        key: :tech_pola,
        type: :bonus
      }
    ]
  end
end
