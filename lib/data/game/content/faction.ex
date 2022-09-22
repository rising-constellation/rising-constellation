defmodule Data.Game.Faction.Content do
  def data do
    [
      %Data.Game.Faction{
        key: :tetrarchy,
        culture: :tetrarchic,
        initial_character_type: :admiral,
        initial_character_spec1: :butcher,
        initial_character_spec2: :strategist,
        initial_character_skills: [1, 2, 2, 0, 0, 0],
        traditions: [
          %{
            key: :tetrarchy_early,
            bonus: %Core.Bonus{from: :direct, to: :player_technology, type: :add, value: 3}
          },
          %{
            key: :tetrarchy_mid,
            bonus: %Core.Bonus{from: :sys_frigate_lvl, to: :sys_frigate_lvl, type: :mul, value: 0.25}
          },
          %{
            key: :tetrarchy_late,
            bonus: %Core.Bonus{from: :army_maintenance, to: :army_maintenance, type: :mul, value: -0.1}
          },
          %{
            key: :tetrarchy_malus,
            bonus: %Core.Bonus{from: :player_ideology, to: :player_ideology, type: :mul, value: -0.05}
          }
        ],
        theme: "dark-blue",
        color: "#3f66df"
      },
      %Data.Game.Faction{
        key: :myrmezir,
        culture: :myrmeziriannic,
        initial_character_type: :speaker,
        initial_character_spec1: :agitator,
        initial_character_spec2: :proselyte,
        initial_character_skills: [1, 2, 2, 0, 0, 0],
        traditions: [
          %{
            key: :myrmezir_early,
            bonus: %Core.Bonus{from: :direct, to: :player_ideology, type: :add, value: 2}
          },
          %{
            key: :myrmezir_mid,
            bonus: %Core.Bonus{from: :speaker_make_dominion, to: :speaker_make_dominion, type: :mul, value: 0.2}
          },
          %{
            key: :myrmezir_late,
            bonus: %Core.Bonus{from: :direct, to: :dominion_rate, type: :add, value: 0.1}
          },
          %{
            key: :myrmezir_malus,
            bonus: %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -5}
          }
        ],
        theme: "red",
        color: "#bc2433"
      },
      %Data.Game.Faction{
        key: :cardan,
        culture: :cardanic,
        initial_character_type: :spy,
        initial_character_spec1: :informer,
        initial_character_spec2: :counter_spy,
        initial_character_skills: [1, 2, 0, 2, 0, 0],
        traditions: [
          %{
            key: :cardan_early,
            bonus: %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 20}
          },
          %{
            key: :cardan_mid,
            bonus: %Core.Bonus{from: :spy_assassination, to: :spy_assassination, type: :mul, value: 0.15}
          },
          %{
            key: :cardan_late,
            bonus: %Core.Bonus{from: :spy_infiltrate, to: :spy_infiltrate, type: :mul, value: 0.15}
          },
          %{
            key: :cardan_malus,
            bonus: %Core.Bonus{from: :player_technology, to: :player_technology, type: :mul, value: -0.05}
          }
        ],
        theme: "purple",
        color: "#8e60bf"
      },
      %Data.Game.Faction{
        key: :synelle,
        culture: :syn,
        initial_character_type: :admiral,
        initial_character_spec1: :defender,
        initial_character_spec2: :shipowner,
        initial_character_skills: [0, 0, 0, 2, 3, 0],
        traditions: [
          %{
            key: :synelle_early,
            bonus: %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 20}
          },
          %{
            key: :synelle_mid,
            bonus: %Core.Bonus{from: :sys_defense, to: :sys_defense, type: :mul, value: 0.1}
          },
          %{
            key: :synelle_late,
            bonus: %Core.Bonus{from: :army_repair, to: :army_repair, type: :mul, value: 0.2}
          },
          %{
            key: :synelle_malus,
            bonus: %Core.Bonus{from: :player_credit, to: :player_credit, type: :mul, value: -0.05}
          }
        ],
        theme: "green",
        color: "#a2cd44"
      },
      %Data.Game.Faction{
        key: :ark,
        culture: :stelloliberalism,
        initial_character_type: :spy,
        initial_character_spec1: :mafioso,
        initial_character_spec2: :counter_spy,
        initial_character_skills: [0, 0, 0, 2, 0, 3],
        traditions: [
          %{
            key: :ark_early,
            bonus: %Core.Bonus{from: :direct, to: :player_credit, type: :add, value: 50}
          },
          %{
            key: :ark_mid,
            bonus: %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 10}
          },
          %{
            key: :ark_late,
            bonus: %Core.Bonus{from: :sys_mobility, to: :sys_mobility, type: :mul, value: 0.15}
          },
          %{
            key: :ark_malus,
            bonus: %Core.Bonus{from: :army_maintenance, to: :army_maintenance, type: :mul, value: 0.05}
          }
        ],
        theme: "yellow",
        color: "#c9a115"
      }
    ]
  end
end
