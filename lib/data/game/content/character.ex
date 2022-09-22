defmodule Data.Game.Character.Content do
  def data do
    [
      %Data.Game.Character{
        key: :admiral,
        initial_protection: 0,
        initial_determination: 0,
        gain_protection: 19,
        max_protection: 475,
        gain_determination: 13,
        max_determination: 325,
        specializations: [
          %{
            key: :strategist,
            index: 0,
            bonus: [%Core.Bonus{from: :direct, value: 20, type: :add, to: :army_repair}]
          },
          %{
            key: :butcher,
            index: 1,
            bonus: [%Core.Bonus{from: :army_raid, value: 0.05, type: :mul, to: :army_raid}]
          },
          %{
            key: :conqueror,
            index: 2,
            bonus: [%Core.Bonus{from: :army_invasion, value: 0.05, type: :mul, to: :army_invasion}]
          },
          %{
            key: :shipowner,
            index: 3,
            bonus: [%Core.Bonus{from: :sys_production, value: 0.05, type: :mul, to: :sys_production}]
          },
          %{
            key: :defender,
            index: 4,
            bonus: [%Core.Bonus{from: :direct, value: 5, type: :add, to: :sys_defense}]
          },
          %{
            key: :instructor,
            index: 5,
            bonus: [
              %Core.Bonus{from: :direct, value: 10, type: :add, to: :sys_fighter_lvl},
              %Core.Bonus{from: :direct, value: 10, type: :add, to: :sys_corvette_lvl},
              %Core.Bonus{from: :direct, value: 10, type: :add, to: :sys_frigate_lvl},
              %Core.Bonus{from: :direct, value: 10, type: :add, to: :sys_capital_lvl}
            ]
          }
        ],
        credit_cost_range: 600..1500,
        technology_cost_range: 200..350,
        ideology_cost_range: 0..0
      },
      %Data.Game.Character{
        key: :spy,
        initial_protection: 0,
        initial_determination: 0,
        gain_protection: 10,
        max_protection: 350,
        gain_determination: 11,
        max_determination: 425,
        specializations: [
          %{
            key: :informer,
            index: 0,
            bonus: [%Core.Bonus{from: :direct, value: 20, type: :add, to: :spy_infiltrate}]
          },
          %{
            key: :assassin,
            index: 1,
            bonus: [%Core.Bonus{from: :direct, value: 18, type: :add, to: :spy_assassination}]
          },
          %{
            key: :saboteur,
            index: 2,
            bonus: [%Core.Bonus{from: :direct, value: 18, type: :add, to: :spy_sabotage}]
          },
          %{
            key: :counter_spy,
            index: 3,
            bonus: [%Core.Bonus{from: :direct, value: 10, type: :add, to: :sys_ci}]
          },
          %{
            key: :cleaner,
            index: 4,
            bonus: [%Core.Bonus{from: :direct, value: 10, type: :add, to: :sys_remove_contact}]
          },
          %{
            key: :mafioso,
            index: 5,
            bonus: [%Core.Bonus{from: :sys_credit, value: 0.05, type: :mul, to: :sys_credit}]
          }
        ],
        credit_cost_range: 1200..2100,
        technology_cost_range: 0..0,
        ideology_cost_range: 100..250
      },
      %Data.Game.Character{
        key: :speaker,
        initial_protection: 0,
        initial_determination: 0,
        gain_protection: 14,
        max_protection: 250,
        gain_determination: 17,
        max_determination: 275,
        specializations: [
          %{
            key: :proselyte,
            index: 0,
            bonus: [%Core.Bonus{from: :direct, value: 10, type: :add, to: :speaker_make_dominion}]
          },
          %{
            key: :agitator,
            index: 1,
            bonus: [%Core.Bonus{from: :direct, value: 14, type: :add, to: :speaker_encourage_hate}]
          },
          %{
            key: :seducer,
            index: 2,
            bonus: [%Core.Bonus{from: :direct, value: 13, type: :add, to: :speaker_conversion}]
          },
          %{
            key: :leader,
            index: 3,
            bonus: [%Core.Bonus{from: :direct, value: 6, type: :add, to: :sys_happiness}]
          },
          %{
            key: :scholar,
            index: 4,
            bonus: [%Core.Bonus{from: :sys_technology, value: 0.05, type: :mul, to: :sys_technology}]
          },
          %{
            key: :philosopher,
            index: 5,
            bonus: [%Core.Bonus{from: :sys_ideology, value: 0.05, type: :mul, to: :sys_ideology}]
          }
        ],
        credit_cost_range: 0..0,
        technology_cost_range: 100..250,
        ideology_cost_range: 200..350
      }
    ]
  end
end
