# credo:disable-for-this-file Credo.Check.Readability.LargeNumbers

defmodule Data.Game.Doctrine.Content.Fast do
  def data do
    [
      %Data.Game.Doctrine{
        ancestor: nil,
        bonus: [
          %Core.Bonus{from: :direct, to: :player_spy, type: :add, value: 1},
          %Core.Bonus{from: :direct, to: :player_admiral, type: :add, value: 1},
          %Core.Bonus{from: :direct, to: :player_speaker, type: :add, value: 1}
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
        cost: 1200,
        illustration: "system_1.jpg",
        key: :system_1,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :system_1,
        bonus: [
          %Core.Bonus{from: :direct, to: :player_dominion, type: :add, value: 3},
          %Core.Bonus{from: :direct, to: :dominion_rate, type: :add, value: 0.2}
        ],
        class: :expansion,
        cost: 3000,
        illustration: "dominion_1.jpg",
        key: :dominion_1,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :dominion_1,
        bonus: [
          %Core.Bonus{from: :direct, to: :player_system, type: :add, value: 2},
          %Core.Bonus{from: :direct, to: :player_dominion, type: :add, value: 4},
          %Core.Bonus{from: :direct, to: :dominion_rate, type: :add, value: 0.2},
          %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -8}
        ],
        class: :expansion,
        cost: 6000,
        illustration: "sys_dom_2.jpg",
        key: :sys_dom_2,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :sys_dom_2,
        bonus: [
          %Core.Bonus{from: :direct, to: :player_system, type: :add, value: 3},
          %Core.Bonus{from: :player_credit, to: :player_credit, type: :mul, value: -0.08},
          %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -16}
        ],
        class: :expansion,
        cost: 8000,
        illustration: "system_4.jpg",
        key: :system_4,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :system_4,
        bonus: [
          %Core.Bonus{from: :direct, to: :player_dominion, type: :add, value: 7},
          %Core.Bonus{from: :direct, to: :dominion_rate, type: :add, value: 0.2},
          %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -12}
        ],
        class: :expansion,
        cost: 10000,
        illustration: "dominion_3.jpg",
        key: :dominion_3,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :agent,
        bonus: [
          %Core.Bonus{from: :direct, to: :player_ideology, type: :add, value: 3},
          %Core.Bonus{from: :direct, to: :player_technology, type: :add, value: 3}
        ],
        class: :expansion,
        cost: 300,
        illustration: "speaker_1.jpg",
        key: :speaker_1,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :speaker_1,
        bonus: [
          %Core.Bonus{from: :direct, to: :player_technology, type: :add, value: 20},
          %Core.Bonus{from: :direct, to: :player_speaker, type: :add, value: 2}
        ],
        class: :expansion,
        cost: 900,
        illustration: "tech_2.jpg",
        key: :tech_2,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :tech_2,
        bonus: [
          %Core.Bonus{from: :player_technology, to: :player_technology, type: :mul, value: 0.3},
          %Core.Bonus{from: :player_ideology, to: :player_ideology, type: :mul, value: -0.06},
          %Core.Bonus{from: :sys_production, to: :sys_production, type: :mul, value: -0.04}
        ],
        class: :expansion,
        cost: 8000,
        illustration: "tech_pola.jpg",
        key: :tech_pola,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :speaker_1,
        bonus: [%Core.Bonus{from: :direct, to: :player_credit, type: :add, value: 100}],
        class: :expansion,
        cost: 700,
        illustration: "credit_1.jpg",
        key: :credit_1,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :credit_1,
        bonus: [%Core.Bonus{from: :direct, to: :player_credit, type: :add, value: 300}],
        class: :expansion,
        cost: 2800,
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
        class: :expansion,
        cost: 3500,
        illustration: "spy_2.jpg",
        key: :spy_2,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :spy_2,
        bonus: [%Core.Bonus{from: :direct, to: :player_credit, type: :add, value: 500}],
        class: :expansion,
        cost: 5000,
        illustration: "credit_3.jpg",
        key: :credit_3,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :credit_3,
        bonus: [%Core.Bonus{from: :direct, to: :sys_mobility, type: :add, value: 20}],
        class: :expansion,
        cost: 8000,
        illustration: "mobility_1.jpg",
        key: :mobility_1,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :mobility_1,
        bonus: [
          %Core.Bonus{from: :sys_mobility, to: :sys_mobility, type: :mul, value: 0.1},
          %Core.Bonus{from: :direct, to: :player_credit, type: :add, value: -100}
        ],
        class: :expansion,
        cost: 11000,
        illustration: "mobility_2.jpg",
        key: :mobility_2,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :credit_3,
        bonus: [
          %Core.Bonus{from: :sys_pop, to: :sys_credit, type: :mul, value: 2},
          %Core.Bonus{from: :sys_defense, to: :sys_defense, type: :mul, value: -0.25}
        ],
        class: :expansion,
        cost: 6000,
        illustration: "credit_pop.jpg",
        key: :credit_pop,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :credit_pop,
        bonus: [
          %Core.Bonus{from: :player_credit, to: :player_credit, type: :mul, value: 0.4},
          %Core.Bonus{from: :player_technology, to: :player_technology, type: :mul, value: -0.1},
          %Core.Bonus{from: :player_ideology, to: :player_ideology, type: :mul, value: -0.1},
          %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -24}
        ],
        class: :expansion,
        cost: 9000,
        illustration: "credit_pola_1.jpg",
        key: :credit_pola_1,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :speaker_1,
        bonus: [%Core.Bonus{from: :direct, to: :player_ideology, type: :add, value: 22}],
        class: :expansion,
        cost: 800,
        illustration: "ideo_2.jpg",
        key: :ideo_2,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :ideo_2,
        bonus: [%Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 40}],
        class: :expansion,
        cost: 2000,
        illustration: "stab_2.jpg",
        key: :stab_2,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :stab_2,
        bonus: [
          %Core.Bonus{from: :player_ideology, to: :player_ideology, type: :mul, value: 0.3},
          %Core.Bonus{from: :player_technology, to: :player_technology, type: :mul, value: -0.06},
          %Core.Bonus{from: :player_credit, to: :player_credit, type: :mul, value: -0.04}
        ],
        class: :expansion,
        cost: 8000,
        illustration: "ideo_pola.jpg",
        key: :ideo_pola,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :agent,
        bonus: [%Core.Bonus{from: :direct, to: :player_admiral, type: :add, value: 2}],
        class: :character,
        cost: 400,
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
        class: :character,
        cost: 1000,
        illustration: "upgrade_raid.jpg",
        key: :upgrade_raid,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :upgrade_raid,
        bonus: [%Core.Bonus{from: :direct, to: :player_admiral, type: :add, value: 4}],
        class: :character,
        cost: 3000,
        illustration: "admiral_2.jpg",
        key: :admiral_2,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :admiral_2,
        bonus: [
          %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 50},
          %Core.Bonus{from: :sys_production, to: :sys_production, type: :mul, value: 0.1}
        ],
        class: :character,
        cost: 4800,
        illustration: "prod_2.jpg",
        key: :prod_2,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :prod_2,
        bonus: [
          %Core.Bonus{from: :direct, to: :player_admiral, type: :add, value: 5},
          %Core.Bonus{from: :direct, to: :player_speaker, type: :add, value: 2},
          %Core.Bonus{from: :player_credit, to: :player_credit, type: :mul, value: -0.04}
        ],
        class: :character,
        cost: 6400,
        illustration: "admiral_4.jpg",
        key: :admiral_4,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :admiral_4,
        bonus: [
          %Core.Bonus{from: :army_maintenance, to: :army_maintenance, type: :mul, value: -0.25}
        ],
        class: :character,
        cost: 9000,
        illustration: "reduce_maintenance_2.jpg",
        key: :reduce_maintenance_2,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :reduce_maintenance_2,
        bonus: [
          %Core.Bonus{from: :army_repair, to: :army_repair, type: :mul, value: 0.2},
          %Core.Bonus{from: :army_invasion, to: :army_invasion, type: :mul, value: 0.08},
          %Core.Bonus{from: :army_raid, to: :army_raid, type: :mul, value: 0.1},
          %Core.Bonus{from: :player_credit, to: :player_credit, type: :mul, value: -0.08}
        ],
        class: :character,
        cost: 10000,
        illustration: "upgrade_fleet.jpg",
        key: :upgrade_fleet,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :reduce_maintenance_2,
        bonus: [
          %Core.Bonus{from: :army_repair, to: :army_repair, type: :mul, value: 0.1},
          %Core.Bonus{from: :sys_production, to: :sys_production, type: :mul, value: 0.12}
        ],
        class: :character,
        cost: 7500,
        illustration: "upgrade_repair.jpg",
        key: :upgrade_repair,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :admiral_1,
        bonus: [
          %Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 30},
          %Core.Bonus{from: :sys_production, to: :sys_production, type: :mul, value: -0.3}
        ],
        class: :character,
        cost: 700,
        illustration: "defense_1.jpg",
        key: :defense_1,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :defense_1,
        bonus: [%Core.Bonus{from: :direct, to: :player_speaker, type: :add, value: 3}],
        class: :character,
        cost: 1800,
        illustration: "speaker_2.jpg",
        key: :speaker_2,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :speaker_2,
        bonus: [
          %Core.Bonus{from: :direct, to: :player_speaker, type: :add, value: 6},
          %Core.Bonus{from: :direct, to: :player_spy, type: :add, value: 2},
          %Core.Bonus{from: :sys_production, to: :sys_production, type: :mul, value: -0.1}
        ],
        class: :character,
        cost: 6600,
        illustration: "speaker_4.jpg",
        key: :speaker_4,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :speaker_4,
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
        class: :character,
        cost: 8500,
        illustration: "speaker_dominion.jpg",
        key: :speaker_dominion,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :defense_1,
        bonus: [
          %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 30},
          %Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 20}
        ],
        class: :character,
        cost: 4000,
        illustration: "spy_def_1.jpg",
        key: :spy_def_1,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :spy_def_1,
        bonus: [
          %Core.Bonus{from: :sys_ci, to: :sys_ci, type: :mul, value: 0.5},
          %Core.Bonus{from: :sys_remove_contact, to: :sys_remove_contact, type: :mul, value: 1},
          %Core.Bonus{from: :player_credit, to: :player_credit, type: :mul, value: 0.05}
        ],
        class: :character,
        cost: 7000,
        illustration: "spy_def_2.jpg",
        key: :spy_def_2,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :defense_1,
        bonus: [%Core.Bonus{from: :direct, to: :player_spy, type: :add, value: 4}],
        class: :character,
        cost: 1500,
        illustration: "spy_1.jpg",
        key: :spy_1,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :spy_1,
        bonus: [%Core.Bonus{from: :direct, to: :spy_infiltrate, type: :add, value: 25}],
        class: :character,
        cost: 3000,
        illustration: "infiltration.jpg",
        key: :infiltration,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :infiltration,
        bonus: [
          %Core.Bonus{from: :direct, to: :player_spy, type: :add, value: 7},
          %Core.Bonus{from: :direct, to: :player_admiral, type: :add, value: 2},
          %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -12}
        ],
        class: :character,
        cost: 6000,
        illustration: "spy_4.jpg",
        key: :spy_4,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :spy_4,
        bonus: [%Core.Bonus{from: :direct, to: :spy_assassination, type: :add, value: 25}],
        class: :character,
        cost: 7000,
        illustration: "assassinate.jpg",
        key: :assassinate,
        type: :bonus
      },
      %Data.Game.Doctrine{
        ancestor: :assassinate,
        bonus: [
          %Core.Bonus{from: :spy_infiltrate, to: :spy_infiltrate, type: :mul, value: 0.25},
          %Core.Bonus{from: :spy_sabotage, to: :spy_sabotage, type: :mul, value: 0.15},
          %Core.Bonus{from: :spy_assassination, to: :spy_assassination, type: :mul, value: 0.15}
        ],
        class: :character,
        cost: 10000,
        illustration: "spy_bonus.jpg",
        key: :spy_bonus,
        type: :bonus
      }
    ]
  end
end
