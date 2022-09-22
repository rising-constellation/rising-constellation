# credo:disable-for-this-file Credo.Check.Readability.LargeNumbers

defmodule Data.Game.Building.Content.Fast do
  def data do
    [
      %Data.Game.Building{
        biome: :open,
        display: :infrastructure,
        illustration: "infra_open.jpg",
        key: :infra_open,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 8.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 12.0}
            ],
            credit: 12000,
            hide_patent?: false,
            level: 1,
            patent: :infra_open_1,
            production: 3000
          }
        ],
        limitation: :unique_body,
        outputs: [:hab, :happiness],
        type: :infrastructure,
        workforce: 2
      },
      %Data.Game.Building{
        biome: :dome,
        display: :infrastructure,
        illustration: "infra_dome.jpg",
        key: :infra_dome,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 8.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 12.0}
            ],
            credit: 15000,
            hide_patent?: false,
            level: 1,
            patent: :infra_open_1,
            production: 3200
          }
        ],
        limitation: :unique_body,
        outputs: [:hab, :happiness],
        type: :infrastructure,
        workforce: 2
      },
      %Data.Game.Building{
        biome: :dome,
        display: :industrial,
        illustration: "mine_dome.jpg",
        key: :mine_dome,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 16.0},
              %Core.Bonus{from: :body_pop, to: :sys_happiness, type: :add, value: -0.25}
            ],
            credit: 3360,
            hide_patent?: false,
            level: 1,
            patent: :infra_open_1,
            production: 840
          }
        ],
        limitation: :none,
        outputs: [:prod],
        type: :normal,
        workforce: 2
      },
      %Data.Game.Building{
        biome: :dome,
        display: :culture,
        illustration: "hab_dome.jpg",
        key: :hab_dome,
        levels: [
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 6.0}],
            credit: 3800,
            hide_patent?: false,
            level: 1,
            patent: :infra_dome_1,
            production: 1250
          }
        ],
        limitation: :none,
        outputs: [:hab],
        type: :normal,
        workforce: 0
      },
      %Data.Game.Building{
        biome: :open,
        display: :life,
        illustration: "hab_open_poor.jpg",
        key: :hab_open_poor,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 9.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -5.0}
            ],
            credit: 2900,
            hide_patent?: false,
            level: 1,
            patent: nil,
            production: 700
          }
        ],
        limitation: :none,
        outputs: [:hab],
        type: :normal,
        workforce: 0
      },
      %Data.Game.Building{
        biome: :open,
        display: :life,
        illustration: "hab_open_rich.jpg",
        key: :hab_open_rich,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 5.0},
              %Core.Bonus{from: :body_act, to: :sys_credit, type: :add, value: 8.0}
            ],
            credit: 3400,
            hide_patent?: false,
            level: 1,
            patent: :infra_dome_1,
            production: 1000
          }
        ],
        limitation: :none,
        outputs: [:hab, :credit],
        type: :normal,
        workforce: 0
      },
      %Data.Game.Building{
        biome: :orbital,
        display: :industrial,
        illustration: "factory_orbital.jpg",
        key: :factory_orbital,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 2.0},
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 12.0}
            ],
            credit: 5040,
            hide_patent?: false,
            level: 1,
            patent: :infra_open_1,
            production: 1120
          }
        ],
        limitation: :none,
        outputs: [:prod, :credit],
        type: :normal,
        workforce: 1
      },
      %Data.Game.Building{
        biome: :dome,
        display: :industrial,
        illustration: "high_factory_dome.jpg",
        key: :high_factory_dome,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 30.0},
              %Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 20.0}
            ],
            credit: 53000,
            hide_patent?: false,
            level: 1,
            patent: :dome_industries,
            production: 6200
          }
        ],
        limitation: :unique_body,
        outputs: [:prod, :tech],
        type: :normal,
        workforce: 5
      },
      %Data.Game.Building{
        biome: :open,
        display: :industrial,
        illustration: "lift_open.jpg",
        key: :lift_open,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 20.0},
              %Core.Bonus{from: :body_ind, to: :sys_mobility, type: :add, value: 5.0}
            ],
            credit: 14000,
            hide_patent?: false,
            level: 1,
            patent: :open_credit,
            production: 3450
          }
        ],
        limitation: :unique_body,
        outputs: [:credit],
        type: :normal,
        workforce: 3
      },
      %Data.Game.Building{
        biome: :open,
        display: :output,
        illustration: "university_open.jpg",
        key: :university_open,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_technology, type: :add, value: 4.0},
              %Core.Bonus{from: :body_pop, to: :sys_technology, type: :add, value: 0.6}
            ],
            credit: 3360,
            hide_patent?: false,
            level: 1,
            patent: nil,
            production: 560
          }
        ],
        limitation: :unique_body,
        outputs: [:tech],
        type: :normal,
        workforce: 2
      },
      %Data.Game.Building{
        biome: :open,
        display: :industrial,
        illustration: "research_open.jpg",
        key: :research_open,
        levels: [
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 22.0}],
            credit: 84000,
            hide_patent?: false,
            level: 1,
            patent: :open_research,
            production: 6160
          }
        ],
        limitation: :unique_body,
        outputs: [:tech],
        type: :normal,
        workforce: 5
      },
      %Data.Game.Building{
        biome: :orbital,
        display: :industrial,
        illustration: "research_orbital.jpg",
        key: :research_orbital,
        levels: [
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 3.0}],
            credit: 6720,
            hide_patent?: false,
            level: 1,
            patent: :orbital_research,
            production: 2130
          }
        ],
        limitation: :unique_body,
        outputs: [:tech],
        type: :normal,
        workforce: 1
      },
      %Data.Game.Building{
        biome: :open,
        display: :output,
        illustration: "ideo_open.jpg",
        key: :ideo_open,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_ideology, type: :add, value: 4.0},
              %Core.Bonus{from: :body_pop, to: :sys_ideology, type: :add, value: 0.6}
            ],
            credit: 3360,
            hide_patent?: false,
            level: 1,
            patent: :citadel,
            production: 1300
          }
        ],
        limitation: :unique_body,
        outputs: [:ideo],
        type: :normal,
        workforce: 2
      },
      %Data.Game.Building{
        biome: :dome,
        display: :culture,
        illustration: "monument_dome.jpg",
        key: :monument_dome,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 20.0},
              %Core.Bonus{from: :sys_pop, to: :sys_ideology, type: :add, value: 1.0}
            ],
            credit: 7280,
            hide_patent?: false,
            level: 1,
            patent: :dome_ideo,
            production: 6230
          }
        ],
        limitation: :unique_system,
        outputs: [:ideo, :happiness],
        type: :normal,
        workforce: 3
      },
      %Data.Game.Building{
        biome: :open,
        display: :output,
        illustration: "ideo_credit_open.jpg",
        key: :ideo_credit_open,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :body_act, to: :sys_ideology, type: :add, value: 7.0},
              %Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 2.0},
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 4.0}
            ],
            credit: 16800,
            hide_patent?: false,
            level: 1,
            patent: :open_island,
            production: 2800
          }
        ],
        limitation: :unique_body,
        outputs: [:ideo, :credit, :happiness],
        type: :normal,
        workforce: 4
      },
      %Data.Game.Building{
        biome: :open,
        display: :output,
        illustration: "market_open.jpg",
        key: :market_open,
        levels: [
          %{
            bonus: [%Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 8.0}],
            credit: 4480,
            hide_patent?: false,
            level: 1,
            patent: :open_credit,
            production: 700
          }
        ],
        limitation: :none,
        outputs: [:credit],
        type: :normal,
        workforce: 2
      },
      %Data.Game.Building{
        biome: :open,
        display: :culture,
        illustration: "finance_open.jpg",
        key: :finance_open,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :sys_mobility, to: :sys_credit, type: :add, value: 25.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -32.0}
            ],
            credit: 62000,
            hide_patent?: false,
            level: 1,
            patent: :open_mobility,
            production: 3900
          }
        ],
        limitation: :unique_body,
        outputs: [:credit],
        type: :normal,
        workforce: 5
      },
      %Data.Game.Building{
        biome: :dome,
        display: :industrial,
        illustration: "spatioport_dome.jpg",
        key: :spatioport_dome,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_mobility, type: :add, value: 15.0},
              %Core.Bonus{from: :body_pop, to: :sys_production, type: :add, value: 2.0}
            ],
            credit: 16000,
            hide_patent?: false,
            level: 1,
            patent: :dome_mobility,
            production: 3080
          }
        ],
        limitation: :unique_body,
        outputs: [:credit, :prod],
        type: :normal,
        workforce: 2
      },
      %Data.Game.Building{
        biome: :orbital,
        display: :finance,
        illustration: "spatioport_orbital.jpg",
        key: :spatioport_orbital,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_mobility, type: :add, value: 5.0},
              %Core.Bonus{from: :direct, to: :sys_credit, type: :add, value: 60.0}
            ],
            credit: 21000,
            hide_patent?: false,
            level: 1,
            patent: :dome_mobility,
            production: 1120
          }
        ],
        limitation: :unique_body,
        outputs: [:credit],
        type: :normal,
        workforce: 2
      },
      %Data.Game.Building{
        biome: :dome,
        display: :defense,
        illustration: "defense_global_dome.jpg",
        key: :defense_global_dome,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 10.0},
              %Core.Bonus{from: :sys_defense, to: :sys_defense, type: :add, value: 1.0}
            ],
            credit: 7000,
            hide_patent?: false,
            level: 1,
            patent: :dome_defense_2,
            production: 1400
          }
        ],
        limitation: :unique_system,
        outputs: [:defense, :happiness],
        type: :normal,
        workforce: 5
      },
      %Data.Game.Building{
        biome: :open,
        display: :defense,
        illustration: "defense_local_open.jpg",
        key: :defense_local_open,
        levels: [
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 24.0}],
            credit: 11000,
            hide_patent?: false,
            level: 1,
            patent: :open_defense,
            production: 1400
          }
        ],
        limitation: :unique_body,
        outputs: [:defense],
        type: :normal,
        workforce: 3
      },
      %Data.Game.Building{
        biome: :dome,
        display: :defense,
        illustration: "defense_local_dome.jpg",
        key: :defense_local_dome,
        levels: [
          %{
            bonus: [%Core.Bonus{from: :body_pop, to: :sys_defense, type: :add, value: 2.0}],
            credit: 11000,
            hide_patent?: false,
            level: 1,
            patent: :open_defense,
            production: 1400
          }
        ],
        limitation: :unique_body,
        outputs: [:defense],
        type: :normal,
        workforce: 3
      },
      %Data.Game.Building{
        biome: :orbital,
        display: :defense,
        illustration: "defense_local_orbital.jpg",
        key: :defense_local_orbital,
        levels: [
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 7.0}],
            credit: 4000,
            hide_patent?: false,
            level: 1,
            patent: :dome_happiness,
            production: 700
          }
        ],
        limitation: :unique_body,
        outputs: [:defense],
        type: :normal,
        workforce: 1
      },
      %Data.Game.Building{
        biome: :open,
        display: :culture,
        illustration: "happy_pot_open.jpg",
        key: :happy_pot_open,
        levels: [
          %{
            bonus: [%Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 25.0}],
            credit: 16800,
            hide_patent?: false,
            level: 1,
            patent: :open_happiness,
            production: 2660
          }
        ],
        limitation: :unique_body,
        outputs: [:happiness],
        type: :normal,
        workforce: 5
      },
      %Data.Game.Building{
        biome: :dome,
        display: :culture,
        illustration: "happy_pot_dome.jpg",
        key: :happy_pot_dome,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 12.0},
              %Core.Bonus{from: :body_act, to: :sys_technology, type: :add, value: 5.0}
            ],
            credit: 6720,
            hide_patent?: false,
            level: 1,
            patent: :dome_happiness,
            production: 1120
          }
        ],
        limitation: :unique_body,
        outputs: [:happiness, :ideo],
        type: :normal,
        workforce: 2
      },
      %Data.Game.Building{
        biome: :orbital,
        display: :finance,
        illustration: "happy_pot_orbital.jpg",
        key: :happy_pot_orbital,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 8.0},
              %Core.Bonus{from: :body_act, to: :sys_credit, type: :add, value: 5.0}
            ],
            credit: 8400,
            hide_patent?: false,
            level: 1,
            patent: :open_research,
            production: 1400
          }
        ],
        limitation: :unique_body,
        outputs: [:happiness, :credit],
        type: :normal,
        workforce: 2
      },
      %Data.Game.Building{
        biome: :orbital,
        display: :shipyard,
        illustration: "shipyard_1_orbital.jpg",
        key: :shipyard_1_orbital,
        levels: [
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 8.0}],
            credit: 5600,
            hide_patent?: false,
            level: 1,
            patent: :shipyard_1,
            production: 2050
          }
        ],
        limitation: :unique_system,
        outputs: [:prod],
        type: :normal,
        workforce: 2
      },
      %Data.Game.Building{
        biome: :orbital,
        display: :shipyard,
        illustration: "shipyard_2_orbital.jpg",
        key: :shipyard_2_orbital,
        levels: [
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 10.0}],
            credit: 9900,
            hide_patent?: false,
            level: 1,
            patent: :shipyard_2,
            production: 2570
          }
        ],
        limitation: :unique_system,
        outputs: [:prod],
        type: :normal,
        workforce: 3
      },
      %Data.Game.Building{
        biome: :orbital,
        display: :shipyard,
        illustration: "shipyard_3_orbital.jpg",
        key: :shipyard_3_orbital,
        levels: [
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 6.0}],
            credit: 14300,
            hide_patent?: false,
            level: 1,
            patent: :shipyard_3,
            production: 3230
          }
        ],
        limitation: :unique_system,
        outputs: [:prod, :defense],
        type: :normal,
        workforce: 4
      },
      %Data.Game.Building{
        biome: :orbital,
        display: :shipyard,
        illustration: "shipyard_4_orbital.jpg",
        key: :shipyard_4_orbital,
        levels: [
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 8.0}],
            credit: 23000,
            hide_patent?: false,
            level: 1,
            patent: :shipyard_4,
            production: 4480
          }
        ],
        limitation: :unique_system,
        outputs: [:prod, :defense],
        type: :normal,
        workforce: 6
      },
      %Data.Game.Building{
        biome: :dome,
        display: :defense,
        illustration: "military_school_dome.jpg",
        key: :military_school_dome,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_fighter_lvl, type: :add, value: 20.0},
              %Core.Bonus{from: :direct, to: :sys_corvette_lvl, type: :add, value: 20.0},
              %Core.Bonus{from: :direct, to: :sys_frigate_lvl, type: :add, value: 20.0},
              %Core.Bonus{from: :direct, to: :sys_capital_lvl, type: :add, value: 20.0}
            ],
            credit: 21000,
            hide_patent?: false,
            level: 1,
            patent: :dome_academy,
            production: 4250
          }
        ],
        limitation: :unique_body,
        outputs: [:defense],
        type: :normal,
        workforce: 3
      },
      %Data.Game.Building{
        biome: :orbital,
        display: :defense,
        illustration: "radar_orbital.jpg",
        key: :radar_orbital,
        levels: [
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_radar, type: :add, value: 2.5}],
            credit: 8400,
            hide_patent?: false,
            level: 1,
            patent: :open_defense,
            production: 1400
          }
        ],
        limitation: :unique_system,
        outputs: [:defense],
        type: :normal,
        workforce: 3
      },
      %Data.Game.Building{
        biome: :open,
        display: :defense,
        illustration: "counterintelligence_open.jpg",
        key: :counterintelligence_open,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 150.0},
              %Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 150.0}
            ],
            credit: 8400,
            hide_patent?: false,
            level: 1,
            patent: :dome_defense_2,
            production: 2800
          }
        ],
        limitation: :unique_system,
        outputs: [:defense],
        type: :normal,
        workforce: 5
      }
    ]
  end
end
