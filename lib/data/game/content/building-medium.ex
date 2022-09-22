# credo:disable-for-this-file Credo.Check.Readability.LargeNumbers

defmodule Data.Game.Building.Content.Medium do
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
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 2.0}
            ],
            credit: 2100,
            hide_patent?: false,
            level: 1,
            patent: :infra_open_1,
            production: 120
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 4.0}
            ],
            credit: 4480,
            hide_patent?: false,
            level: 2,
            patent: :infra_open_2,
            production: 120
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 6.0}
            ],
            credit: 7280,
            hide_patent?: false,
            level: 3,
            patent: :infra_open_3,
            production: 720
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 8.0}
            ],
            credit: 10500,
            hide_patent?: false,
            level: 4,
            patent: :infra_open_4,
            production: 1440
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 10.0}
            ],
            credit: 14000,
            hide_patent?: false,
            level: 5,
            patent: :infra_open_5,
            production: 2400
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
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 2.0}
            ],
            credit: 2250,
            hide_patent?: false,
            level: 1,
            patent: :infra_dome_1,
            production: 130
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 4.0}
            ],
            credit: 4800,
            hide_patent?: false,
            level: 2,
            patent: :infra_dome_2,
            production: 160
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 6.0}
            ],
            credit: 7800,
            hide_patent?: false,
            level: 3,
            patent: :infra_dome_3,
            production: 960
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 8.0}
            ],
            credit: 11250,
            hide_patent?: false,
            level: 4,
            patent: :infra_dome_4,
            production: 1920
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 10.0}
            ],
            credit: 15000,
            hide_patent?: false,
            level: 5,
            patent: :infra_dome_5,
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
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 2.8},
              %Core.Bonus{from: :body_pop, to: :sys_happiness, type: :add, value: -0.05}
            ],
            credit: 490,
            hide_patent?: false,
            level: 1,
            patent: :infra_dome_1,
            production: 200
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 4.2},
              %Core.Bonus{from: :body_pop, to: :sys_happiness, type: :add, value: -0.1}
            ],
            credit: 1040,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 160
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 6.3},
              %Core.Bonus{from: :body_pop, to: :sys_happiness, type: :add, value: -0.15}
            ],
            credit: 1690,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 960
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 9.1},
              %Core.Bonus{from: :body_pop, to: :sys_happiness, type: :add, value: -0.2}
            ],
            credit: 2437,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 1920
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 14.0},
              %Core.Bonus{from: :body_pop, to: :sys_happiness, type: :add, value: -0.25}
            ],
            credit: 3250,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 3200
          }
        ],
        limitation: :none,
        outputs: [:prod],
        type: :normal,
        workforce: 2
      },
      %Data.Game.Building{
        biome: :orbital,
        display: :industrial,
        illustration: "mine_orbital.jpg",
        key: :mine_orbital,
        levels: [
          %{
            bonus: [%Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 3.0}],
            credit: 975,
            hide_patent?: false,
            level: 1,
            patent: :orbital_prod,
            production: 300
          },
          %{
            bonus: [%Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 4.8}],
            credit: 2080,
            hide_patent?: true,
            level: 2,
            patent: :infra_orbital_2,
            production: 200
          },
          %{
            bonus: [%Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 7.8}],
            credit: 3380,
            hide_patent?: true,
            level: 3,
            patent: :infra_orbital_3,
            production: 1200
          },
          %{
            bonus: [%Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 11.25}],
            credit: 4875,
            hide_patent?: true,
            level: 4,
            patent: :infra_orbital_4,
            production: 2400
          },
          %{
            bonus: [%Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 15.0}],
            credit: 6500,
            hide_patent?: true,
            level: 5,
            patent: :infra_orbital_5,
            production: 4000
          }
        ],
        limitation: :none,
        outputs: [:prod],
        type: :normal,
        workforce: 1
      },
      %Data.Game.Building{
        biome: :open,
        display: :life,
        illustration: "hab_open.jpg",
        key: :hab_open,
        levels: [
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 3.0}],
            credit: 490,
            hide_patent?: false,
            level: 1,
            patent: nil,
            production: 30
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 3.25}],
            credit: 1040,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 40
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 3.5}],
            credit: 1690,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 240
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 3.75}],
            credit: 2437,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 480
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 4.0}],
            credit: 3250,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 800
          }
        ],
        limitation: :none,
        outputs: [:hab],
        type: :normal,
        workforce: 0
      },
      %Data.Game.Building{
        biome: :dome,
        display: :life,
        illustration: "hab_dome.jpg",
        key: :hab_dome,
        levels: [
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 3.0}],
            credit: 865,
            hide_patent?: false,
            level: 1,
            patent: :dome_pop,
            production: 200
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 3.75}],
            credit: 1840,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 160
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 4.5}],
            credit: 2990,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 960
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 5.25}],
            credit: 4312,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 1920
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 6.0}],
            credit: 5750,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 3200
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
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 4.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -1.0}
            ],
            credit: 1125,
            hide_patent?: false,
            level: 1,
            patent: :open_industries,
            production: 300
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 5.5},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -2.0}
            ],
            credit: 2400,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 200
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 7.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -3.0}
            ],
            credit: 3900,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 1200
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 8.5},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -4.0}
            ],
            credit: 5625,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 2400
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -5.0}
            ],
            credit: 7500,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 4000
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
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 3.0},
              %Core.Bonus{from: :body_act, to: :sys_credit, type: :add, value: 5.0}
            ],
            credit: 1875,
            hide_patent?: false,
            level: 1,
            patent: :open_credit,
            production: 450
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 3.5},
              %Core.Bonus{from: :body_act, to: :sys_credit, type: :add, value: 12.8}
            ],
            credit: 4000,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 600
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 4.0},
              %Core.Bonus{from: :body_act, to: :sys_credit, type: :add, value: 20.8}
            ],
            credit: 6500,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 3600
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 4.5},
              %Core.Bonus{from: :body_act, to: :sys_credit, type: :add, value: 30.0}
            ],
            credit: 9375,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 7200
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 5.0},
              %Core.Bonus{from: :body_act, to: :sys_credit, type: :add, value: 40.0}
            ],
            credit: 12500,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 12000
          }
        ],
        limitation: :none,
        outputs: [:hab, :credit],
        type: :normal,
        workforce: 0
      },
      %Data.Game.Building{
        biome: :open,
        display: :industrial,
        illustration: "factory_open.jpg",
        key: :factory_open,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 3.0},
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 6.0},
              %Core.Bonus{from: :body_pop, to: :sys_happiness, type: :add, value: -0.05}
            ],
            credit: 1500,
            hide_patent?: false,
            level: 1,
            patent: :open_industries,
            production: 500
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 4.5},
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 9.6},
              %Core.Bonus{from: :body_pop, to: :sys_happiness, type: :add, value: -0.1}
            ],
            credit: 3200,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 440
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 6.75},
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 15.6},
              %Core.Bonus{from: :body_pop, to: :sys_happiness, type: :add, value: -0.15}
            ],
            credit: 5200,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 4400
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 9.75},
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 22.5},
              %Core.Bonus{from: :body_pop, to: :sys_happiness, type: :add, value: -0.2}
            ],
            credit: 7500,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 9680
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 15.0},
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 30.0},
              %Core.Bonus{from: :body_pop, to: :sys_happiness, type: :add, value: -0.25}
            ],
            credit: 10000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 17600
          }
        ],
        limitation: :none,
        outputs: [:prod, :credit],
        type: :normal,
        workforce: 2
      },
      %Data.Game.Building{
        biome: :orbital,
        display: :industrial,
        illustration: "factory_orbital.jpg",
        key: :factory_orbital,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 1.0},
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 5.0}
            ],
            credit: 500,
            hide_patent?: false,
            level: 1,
            patent: :orbital_credit,
            production: 120
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 1.8},
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 12.0}
            ],
            credit: 1600,
            hide_patent?: true,
            level: 2,
            patent: :infra_orbital_2,
            production: 320
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 2.4},
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 16.0}
            ],
            credit: 2600,
            hide_patent?: true,
            level: 3,
            patent: :infra_orbital_3,
            production: 3200
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 2.7},
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 18.0}
            ],
            credit: 3750,
            hide_patent?: true,
            level: 4,
            patent: :infra_orbital_4,
            production: 7040
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 3.0},
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 20.0}
            ],
            credit: 5000,
            hide_patent?: true,
            level: 5,
            patent: :infra_orbital_5,
            production: 12800
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
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 7.0},
              %Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 2.1}
            ],
            credit: 45000,
            hide_patent?: false,
            level: 1,
            patent: :dome_industries,
            production: 5000
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 12.0},
              %Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 7.5}
            ],
            credit: 71250,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 9600
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 18.0},
              %Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 12.0}
            ],
            credit: 97500,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 19200
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 26.0},
              %Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 19.5}
            ],
            credit: 123_750,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 38400
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 40.0},
              %Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 30.0}
            ],
            credit: 150_000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 76800
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
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 8.0},
              %Core.Bonus{from: :body_ind, to: :sys_mobility, type: :add, value: 1.6}
            ],
            credit: 17500,
            hide_patent?: false,
            level: 1,
            patent: :open_lift,
            production: 1000
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 12.0},
              %Core.Bonus{from: :body_ind, to: :sys_mobility, type: :add, value: 2.4}
            ],
            credit: 28000,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 1280
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 18.0},
              %Core.Bonus{from: :body_ind, to: :sys_mobility, type: :add, value: 3.6}
            ],
            credit: 45500,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 7680
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 26.0},
              %Core.Bonus{from: :body_ind, to: :sys_mobility, type: :add, value: 5.2}
            ],
            credit: 65625,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 15360
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 40.0},
              %Core.Bonus{from: :body_ind, to: :sys_mobility, type: :add, value: 8.0}
            ],
            credit: 87500,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 25600
          }
        ],
        limitation: :unique_body,
        outputs: [:credit],
        type: :normal,
        workforce: 3
      },
      %Data.Game.Building{
        biome: :dome,
        display: :industrial,
        illustration: "lift_dome.jpg",
        key: :lift_dome,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 1.2},
              %Core.Bonus{from: :body_ind, to: :sys_mobility, type: :add, value: 1.2}
            ],
            credit: 5625,
            hide_patent?: false,
            level: 1,
            patent: :dome_mobility,
            production: 750
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 1.5},
              %Core.Bonus{from: :body_ind, to: :sys_mobility, type: :add, value: 1.8}
            ],
            credit: 12000,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 960
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 2.4},
              %Core.Bonus{from: :body_ind, to: :sys_mobility, type: :add, value: 2.7}
            ],
            credit: 19500,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 2880
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 3.9},
              %Core.Bonus{from: :body_ind, to: :sys_mobility, type: :add, value: 3.9}
            ],
            credit: 28125,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 7680
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 6.0},
              %Core.Bonus{from: :body_ind, to: :sys_mobility, type: :add, value: 6.0}
            ],
            credit: 37500,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 19200
          }
        ],
        limitation: :unique_body,
        outputs: [:credit, :prod],
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
              %Core.Bonus{from: :direct, to: :sys_technology, type: :add, value: 3.0},
              %Core.Bonus{from: :body_pop, to: :sys_technology, type: :add, value: 0.15}
            ],
            credit: 375,
            hide_patent?: false,
            level: 1,
            patent: nil,
            production: 70
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_technology, type: :add, value: 3.0},
              %Core.Bonus{from: :body_pop, to: :sys_technology, type: :add, value: 0.26}
            ],
            credit: 800,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 60
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_technology, type: :add, value: 3.0},
              %Core.Bonus{from: :body_pop, to: :sys_technology, type: :add, value: 0.38}
            ],
            credit: 1300,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 600
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_technology, type: :add, value: 3.0},
              %Core.Bonus{from: :body_pop, to: :sys_technology, type: :add, value: 0.49}
            ],
            credit: 1875,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 1320
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_technology, type: :add, value: 3.0},
              %Core.Bonus{from: :body_pop, to: :sys_technology, type: :add, value: 0.6}
            ],
            credit: 2500,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 2400
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
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 3.0}],
            credit: 18000,
            hide_patent?: false,
            level: 1,
            patent: :open_research,
            production: 8000
          },
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 4.5}],
            credit: 36000,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 7000
          },
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 6.75}],
            credit: 54000,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 14000
          },
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 9.75}],
            credit: 72000,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 28000
          },
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 15.0}],
            credit: 90000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 56000
          }
        ],
        limitation: :unique_body,
        outputs: [:tech],
        type: :normal,
        workforce: 5
      },
      %Data.Game.Building{
        biome: :dome,
        display: :industrial,
        illustration: "research_dome.jpg",
        key: :research_dome,
        levels: [
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 1.2}],
            credit: 940,
            hide_patent?: false,
            level: 1,
            patent: :infra_dome_1,
            production: 250
          },
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 1.8}],
            credit: 2000,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 280
          },
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 2.7}],
            credit: 3250,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 2800
          },
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 3.9}],
            credit: 4687,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 6160
          },
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 6.0}],
            credit: 6250,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 11200
          }
        ],
        limitation: :unique_body,
        outputs: [:tech],
        type: :normal,
        workforce: 1
      },
      %Data.Game.Building{
        biome: :orbital,
        display: :industrial,
        illustration: "research_orbital.jpg",
        key: :research_orbital,
        levels: [
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 0.6}],
            credit: 1500,
            hide_patent?: false,
            level: 1,
            patent: :orbital_research,
            production: 150
          },
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 1.2}],
            credit: 3200,
            hide_patent?: true,
            level: 2,
            patent: :infra_orbital_2,
            production: 160
          },
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 1.8}],
            credit: 5200,
            hide_patent?: true,
            level: 3,
            patent: :infra_orbital_3,
            production: 1600
          },
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 2.6}],
            credit: 7500,
            hide_patent?: true,
            level: 4,
            patent: :infra_orbital_4,
            production: 3520
          },
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 4.0}],
            credit: 10000,
            hide_patent?: true,
            level: 5,
            patent: :infra_orbital_5,
            production: 6400
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
              %Core.Bonus{from: :direct, to: :sys_ideology, type: :add, value: 3.0},
              %Core.Bonus{from: :body_pop, to: :sys_ideology, type: :add, value: 0.15}
            ],
            credit: 375,
            hide_patent?: false,
            level: 1,
            patent: :citadel,
            production: 120
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_ideology, type: :add, value: 3.0},
              %Core.Bonus{from: :body_pop, to: :sys_ideology, type: :add, value: 0.26}
            ],
            credit: 800,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 60
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_ideology, type: :add, value: 3.0},
              %Core.Bonus{from: :body_pop, to: :sys_ideology, type: :add, value: 0.38}
            ],
            credit: 1300,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 600
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_ideology, type: :add, value: 3.0},
              %Core.Bonus{from: :body_pop, to: :sys_ideology, type: :add, value: 0.49}
            ],
            credit: 1875,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 1320
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_ideology, type: :add, value: 3.0},
              %Core.Bonus{from: :body_pop, to: :sys_ideology, type: :add, value: 0.6}
            ],
            credit: 2500,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 2400
          }
        ],
        limitation: :unique_body,
        outputs: [:ideo],
        type: :normal,
        workforce: 2
      },
      %Data.Game.Building{
        biome: :dome,
        display: :life,
        illustration: "ideo_dome.jpg",
        key: :ideo_dome,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :body_pop, to: :sys_ideology, type: :add, value: 0.3},
              %Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 0.4}
            ],
            credit: 750,
            hide_patent?: false,
            level: 1,
            patent: :dome_happiness,
            production: 750
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_pop, to: :sys_ideology, type: :add, value: 0.45},
              %Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 0.8}
            ],
            credit: 1600,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 1200
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_pop, to: :sys_ideology, type: :add, value: 0.68},
              %Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 1.2}
            ],
            credit: 2600,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 3600
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_pop, to: :sys_ideology, type: :add, value: 0.98},
              %Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 1.6}
            ],
            credit: 3750,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 9600
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_pop, to: :sys_ideology, type: :add, value: 1.5},
              %Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 2.0}
            ],
            credit: 5000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 24000
          }
        ],
        limitation: :unique_body,
        outputs: [:ideo],
        type: :normal,
        workforce: 2
      },
      %Data.Game.Building{
        biome: :open,
        display: :culture,
        illustration: "monument_open.jpg",
        key: :monument_open,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 1.6},
              %Core.Bonus{from: :direct, to: :sys_ideology, type: :add, value: 3.75}
            ],
            credit: 3750,
            hide_patent?: false,
            level: 1,
            patent: :open_ideo,
            production: 500
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 3.0},
              %Core.Bonus{from: :direct, to: :sys_ideology, type: :add, value: 9.0}
            ],
            credit: 8000,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 760
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 4.5},
              %Core.Bonus{from: :direct, to: :sys_ideology, type: :add, value: 13.5}
            ],
            credit: 13000,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 2280
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 6.5},
              %Core.Bonus{from: :direct, to: :sys_ideology, type: :add, value: 19.5}
            ],
            credit: 18750,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 6080
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_ideology, type: :add, value: 30.0}
            ],
            credit: 25000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 15200
          }
        ],
        limitation: :unique_body,
        outputs: [:ideo, :happiness],
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
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 5.0},
              %Core.Bonus{from: :sys_pop, to: :sys_ideology, type: :add, value: 0.2}
            ],
            credit: 40000,
            hide_patent?: false,
            level: 1,
            patent: :dome_ideo,
            production: 6000
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 9.0},
              %Core.Bonus{from: :sys_pop, to: :sys_ideology, type: :add, value: 0.5}
            ],
            credit: 56250,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 9000
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 13.5},
              %Core.Bonus{from: :sys_pop, to: :sys_ideology, type: :add, value: 0.8}
            ],
            credit: 72500,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 18000
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 19.5},
              %Core.Bonus{from: :sys_pop, to: :sys_ideology, type: :add, value: 1.3}
            ],
            credit: 88750,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 36000
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 30.0},
              %Core.Bonus{from: :sys_pop, to: :sys_ideology, type: :add, value: 2.0}
            ],
            credit: 105_000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 72000
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
              %Core.Bonus{from: :body_act, to: :sys_ideology, type: :add, value: 1.0},
              %Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 1.0},
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 1.0}
            ],
            credit: 12500,
            hide_patent?: false,
            level: 1,
            patent: :open_island,
            production: 1300
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_act, to: :sys_ideology, type: :add, value: 2.56},
              %Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 2.4},
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 2.0}
            ],
            credit: 25000,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 1360
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_act, to: :sys_ideology, type: :add, value: 4.16},
              %Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 3.6},
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 3.0}
            ],
            credit: 37500,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 4080
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_act, to: :sys_ideology, type: :add, value: 6.0},
              %Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 5.2},
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 4.0}
            ],
            credit: 50000,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 10880
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_act, to: :sys_ideology, type: :add, value: 8.0},
              %Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 8.0},
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 5.0}
            ],
            credit: 62500,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 27200
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
            bonus: [%Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 2.0}],
            credit: 1000,
            hide_patent?: false,
            level: 1,
            patent: :open_credit,
            production: 200
          },
          %{
            bonus: [%Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 4.0}],
            credit: 3200,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 220
          },
          %{
            bonus: [%Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 6.0}],
            credit: 5200,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 2200
          },
          %{
            bonus: [%Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 8.0}],
            credit: 7500,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 4840
          },
          %{
            bonus: [%Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 10.0}],
            credit: 10000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 8800
          }
        ],
        limitation: :none,
        outputs: [:credit],
        type: :normal,
        workforce: 2
      },
      %Data.Game.Building{
        biome: :dome,
        display: :life,
        illustration: "market_dome.jpg",
        key: :market_dome,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 1.2},
              %Core.Bonus{from: :direct, to: :sys_technology, type: :add, value: 1.2}
            ],
            credit: 2000,
            hide_patent?: false,
            level: 1,
            patent: :dome_pop,
            production: 150
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 2.4},
              %Core.Bonus{from: :direct, to: :sys_technology, type: :add, value: 2.4}
            ],
            credit: 4000,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 180
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 3.6},
              %Core.Bonus{from: :direct, to: :sys_technology, type: :add, value: 3.6}
            ],
            credit: 6500,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 1800
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 4.8},
              %Core.Bonus{from: :direct, to: :sys_technology, type: :add, value: 4.8}
            ],
            credit: 9375,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 3960
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 6.0},
              %Core.Bonus{from: :direct, to: :sys_technology, type: :add, value: 6.0}
            ],
            credit: 12500,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 7200
          }
        ],
        limitation: :none,
        outputs: [:credit, :tech],
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
              %Core.Bonus{from: :sys_mobility, to: :sys_credit, type: :add, value: 2.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -6.4}
            ],
            credit: 35000,
            hide_patent?: false,
            level: 1,
            patent: :open_mobility,
            production: 6000
          },
          %{
            bonus: [
              %Core.Bonus{from: :sys_mobility, to: :sys_credit, type: :add, value: 4.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -12.8}
            ],
            credit: 50625,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 8700
          },
          %{
            bonus: [
              %Core.Bonus{from: :sys_mobility, to: :sys_credit, type: :add, value: 6.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -19.2}
            ],
            credit: 66250,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 17400
          },
          %{
            bonus: [
              %Core.Bonus{from: :sys_mobility, to: :sys_credit, type: :add, value: 8.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -25.6}
            ],
            credit: 81875,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 34800
          },
          %{
            bonus: [
              %Core.Bonus{from: :sys_mobility, to: :sys_credit, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -32.0}
            ],
            credit: 97500,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 69600
          }
        ],
        limitation: :unique_body,
        outputs: [:credit],
        type: :normal,
        workforce: 5
      },
      %Data.Game.Building{
        biome: :orbital,
        display: :finance,
        illustration: "finance_orbital.jpg",
        key: :finance_orbital,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :sys_mobility, to: :sys_credit, type: :add, value: 1.2},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -3.6}
            ],
            credit: 10000,
            hide_patent?: false,
            level: 1,
            patent: :orbital_mobility,
            production: 1500
          },
          %{
            bonus: [
              %Core.Bonus{from: :sys_mobility, to: :sys_credit, type: :add, value: 2.4},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -7.2}
            ],
            credit: 17500,
            hide_patent?: true,
            level: 2,
            patent: :infra_orbital_2,
            production: 1520
          },
          %{
            bonus: [
              %Core.Bonus{from: :sys_mobility, to: :sys_credit, type: :add, value: 3.6},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -10.8}
            ],
            credit: 25000,
            hide_patent?: true,
            level: 3,
            patent: :infra_orbital_3,
            production: 9120
          },
          %{
            bonus: [
              %Core.Bonus{from: :sys_mobility, to: :sys_credit, type: :add, value: 4.8},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -14.4}
            ],
            credit: 32500,
            hide_patent?: true,
            level: 4,
            patent: :infra_orbital_4,
            production: 18240
          },
          %{
            bonus: [
              %Core.Bonus{from: :sys_mobility, to: :sys_credit, type: :add, value: 6.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -18.0}
            ],
            credit: 40000,
            hide_patent?: true,
            level: 5,
            patent: :infra_orbital_5,
            production: 30400
          }
        ],
        limitation: :unique_body,
        outputs: [:credit],
        type: :normal,
        workforce: 3
      },
      %Data.Game.Building{
        biome: :dome,
        display: :culture,
        illustration: "spatioport_dome.jpg",
        key: :spatioport_dome,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_mobility, type: :add, value: 1.6},
              %Core.Bonus{from: :body_pop, to: :sys_production, type: :add, value: 0.4}
            ],
            credit: 2250,
            hide_patent?: false,
            level: 1,
            patent: :dome_mobility,
            production: 1000
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_mobility, type: :add, value: 3.2},
              %Core.Bonus{from: :body_pop, to: :sys_production, type: :add, value: 0.8}
            ],
            credit: 4800,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 800
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_mobility, type: :add, value: 4.8},
              %Core.Bonus{from: :body_pop, to: :sys_production, type: :add, value: 1.2}
            ],
            credit: 7800,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 2400
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_mobility, type: :add, value: 6.4},
              %Core.Bonus{from: :body_pop, to: :sys_production, type: :add, value: 1.6}
            ],
            credit: 11250,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 6400
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_mobility, type: :add, value: 8.0},
              %Core.Bonus{from: :body_pop, to: :sys_production, type: :add, value: 2.0}
            ],
            credit: 15000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 16000
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
              %Core.Bonus{from: :direct, to: :sys_mobility, type: :add, value: 1.5},
              %Core.Bonus{from: :direct, to: :sys_credit, type: :add, value: 20.0}
            ],
            credit: 5000,
            hide_patent?: false,
            level: 1,
            patent: :orbital_mobility,
            production: 1200
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_mobility, type: :add, value: 3.0},
              %Core.Bonus{from: :direct, to: :sys_credit, type: :add, value: 40.0}
            ],
            credit: 8000,
            hide_patent?: true,
            level: 2,
            patent: :infra_orbital_2,
            production: 880
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_mobility, type: :add, value: 4.5},
              %Core.Bonus{from: :direct, to: :sys_credit, type: :add, value: 60.0}
            ],
            credit: 13000,
            hide_patent?: true,
            level: 3,
            patent: :infra_orbital_3,
            production: 5280
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_mobility, type: :add, value: 6.0},
              %Core.Bonus{from: :direct, to: :sys_credit, type: :add, value: 80.0}
            ],
            credit: 18750,
            hide_patent?: true,
            level: 4,
            patent: :infra_orbital_4,
            production: 10560
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_mobility, type: :add, value: 7.5},
              %Core.Bonus{from: :direct, to: :sys_credit, type: :add, value: 100.0}
            ],
            credit: 25000,
            hide_patent?: true,
            level: 5,
            patent: :infra_orbital_5,
            production: 17600
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
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 2.0},
              %Core.Bonus{from: :sys_defense, to: :sys_defense, type: :add, value: 0.2}
            ],
            credit: 4875,
            hide_patent?: false,
            level: 1,
            patent: :dome_defense_2,
            production: 3000
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 4.0},
              %Core.Bonus{from: :sys_defense, to: :sys_defense, type: :add, value: 0.4}
            ],
            credit: 10400,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 2200
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 6.0},
              %Core.Bonus{from: :sys_defense, to: :sys_defense, type: :add, value: 0.6}
            ],
            credit: 16900,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 4400
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 8.0},
              %Core.Bonus{from: :sys_defense, to: :sys_defense, type: :add, value: 0.8}
            ],
            credit: 24375,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 8800
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 10.0},
              %Core.Bonus{from: :sys_defense, to: :sys_defense, type: :add, value: 1.0}
            ],
            credit: 32500,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 17600
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
            bonus: [%Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 4.8}],
            credit: 2800,
            hide_patent?: false,
            level: 1,
            patent: :open_defense,
            production: 1000
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 9.6}],
            credit: 6000,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 560
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 14.4}],
            credit: 9750,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 1680
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 19.2}],
            credit: 14062,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 4480
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 24.0}],
            credit: 18750,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 11200
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
            bonus: [%Core.Bonus{from: :body_pop, to: :sys_defense, type: :add, value: 0.4}],
            credit: 2400,
            hide_patent?: false,
            level: 1,
            patent: :dome_defense_1,
            production: 800
          },
          %{
            bonus: [%Core.Bonus{from: :body_pop, to: :sys_defense, type: :add, value: 0.8}],
            credit: 5200,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 480
          },
          %{
            bonus: [%Core.Bonus{from: :body_pop, to: :sys_defense, type: :add, value: 1.2}],
            credit: 8450,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 1440
          },
          %{
            bonus: [%Core.Bonus{from: :body_pop, to: :sys_defense, type: :add, value: 1.6}],
            credit: 12187,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 3840
          },
          %{
            bonus: [%Core.Bonus{from: :body_pop, to: :sys_defense, type: :add, value: 2.0}],
            credit: 16250,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 9600
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
            bonus: [%Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 3.0}],
            credit: 930,
            hide_patent?: false,
            level: 1,
            patent: :orbital_defense,
            production: 100
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 4.75}],
            credit: 2000,
            hide_patent?: true,
            level: 2,
            patent: :infra_orbital_2,
            production: 40
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 6.5}],
            credit: 3250,
            hide_patent?: true,
            level: 3,
            patent: :infra_orbital_3,
            production: 240
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 8.25}],
            credit: 4687,
            hide_patent?: true,
            level: 4,
            patent: :infra_orbital_4,
            production: 480
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 10.0}],
            credit: 6250,
            hide_patent?: true,
            level: 5,
            patent: :infra_orbital_5,
            production: 800
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
            bonus: [%Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 5.0}],
            credit: 16000,
            hide_patent?: false,
            level: 1,
            patent: :open_happiness,
            production: 5000
          },
          %{
            bonus: [%Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 10.0}],
            credit: 21750,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 5400
          },
          %{
            bonus: [%Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 15.0}],
            credit: 32625,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 10800
          },
          %{
            bonus: [%Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 20.0}],
            credit: 47125,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 21600
          },
          %{
            bonus: [%Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 25.0}],
            credit: 72500,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 43200
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
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 2.4},
              %Core.Bonus{from: :body_act, to: :sys_technology, type: :add, value: 0.6}
            ],
            credit: 5050,
            hide_patent?: false,
            level: 1,
            patent: :dome_happiness,
            production: 600
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 4.8},
              %Core.Bonus{from: :body_act, to: :sys_technology, type: :add, value: 1.2}
            ],
            credit: 10800,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 384
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 7.2},
              %Core.Bonus{from: :body_act, to: :sys_technology, type: :add, value: 1.8}
            ],
            credit: 17550,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 1152
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 9.6},
              %Core.Bonus{from: :body_act, to: :sys_technology, type: :add, value: 2.4}
            ],
            credit: 25312,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 3072
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 12.0},
              %Core.Bonus{from: :body_act, to: :sys_technology, type: :add, value: 3.0}
            ],
            credit: 33750,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 7680
          }
        ],
        limitation: :unique_body,
        outputs: [:happiness, :ideo],
        type: :normal,
        workforce: 2
      },
      %Data.Game.Building{
        biome: :orbital,
        display: :life,
        illustration: "happy_pot_orbital.jpg",
        key: :happy_pot_orbital,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 2.0},
              %Core.Bonus{from: :body_act, to: :sys_credit, type: :add, value: 2.0}
            ],
            credit: 2475,
            hide_patent?: false,
            level: 1,
            patent: :orbital_happiness,
            production: 800
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 3.5},
              %Core.Bonus{from: :body_act, to: :sys_credit, type: :add, value: 3.5}
            ],
            credit: 5280,
            hide_patent?: true,
            level: 2,
            patent: :infra_orbital_2,
            production: 512
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 5.0},
              %Core.Bonus{from: :body_act, to: :sys_credit, type: :add, value: 5.0}
            ],
            credit: 8580,
            hide_patent?: true,
            level: 3,
            patent: :infra_orbital_3,
            production: 1536
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 6.5},
              %Core.Bonus{from: :body_act, to: :sys_credit, type: :add, value: 6.5}
            ],
            credit: 12375,
            hide_patent?: true,
            level: 4,
            patent: :infra_orbital_4,
            production: 4096
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 8.0},
              %Core.Bonus{from: :body_act, to: :sys_credit, type: :add, value: 8.0}
            ],
            credit: 16500,
            hide_patent?: true,
            level: 5,
            patent: :infra_orbital_5,
            production: 10240
          }
        ],
        limitation: :unique_body,
        outputs: [:happiness, :credit],
        type: :normal,
        workforce: 2
      },
      %Data.Game.Building{
        biome: :orbital,
        display: :life,
        illustration: "happy_orbital.jpg",
        key: :happy_orbital,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 3.0},
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 1.0}
            ],
            credit: 825,
            hide_patent?: false,
            level: 1,
            patent: :orbital_defense,
            production: 200
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 6.0},
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 2.25}
            ],
            credit: 1760,
            hide_patent?: true,
            level: 2,
            patent: :infra_orbital_2,
            production: 240
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 9.0},
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 3.5}
            ],
            credit: 2860,
            hide_patent?: true,
            level: 3,
            patent: :infra_orbital_3,
            production: 2400
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 12.0},
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 4.75}
            ],
            credit: 4125,
            hide_patent?: true,
            level: 4,
            patent: :infra_orbital_4,
            production: 5280
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 15.0},
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 6.0}
            ],
            credit: 5500,
            hide_patent?: true,
            level: 5,
            patent: :infra_orbital_5,
            production: 9600
          }
        ],
        limitation: :unique_body,
        outputs: [:happiness],
        type: :normal,
        workforce: 1
      },
      %Data.Game.Building{
        biome: :orbital,
        display: :shipyard,
        illustration: "shipyard_1_orbital.jpg",
        key: :shipyard_1_orbital,
        levels: [
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 2.0},
              %Core.Bonus{from: :direct, to: :sys_fighter_lvl, type: :add, value: 3.0}
            ],
            credit: 2625,
            hide_patent?: false,
            level: 1,
            patent: :shipyard_1,
            production: 400
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 17.5},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 4.0},
              %Core.Bonus{from: :direct, to: :sys_fighter_lvl, type: :add, value: 6.0}
            ],
            credit: 6343,
            hide_patent?: true,
            level: 2,
            patent: :infra_orbital_2,
            production: 256
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 25.0},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 6.0},
              %Core.Bonus{from: :direct, to: :sys_fighter_lvl, type: :add, value: 9.0}
            ],
            credit: 10062,
            hide_patent?: true,
            level: 3,
            patent: :infra_orbital_3,
            production: 768
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 32.5},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 8.0},
              %Core.Bonus{from: :direct, to: :sys_fighter_lvl, type: :add, value: 12.0}
            ],
            credit: 13781,
            hide_patent?: true,
            level: 4,
            patent: :infra_orbital_4,
            production: 2048
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 40.0},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_fighter_lvl, type: :add, value: 15.0}
            ],
            credit: 17500,
            hide_patent?: true,
            level: 5,
            patent: :infra_orbital_5,
            production: 5120
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
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 15.0},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 3.0},
              %Core.Bonus{from: :direct, to: :sys_corvette_lvl, type: :add, value: 3.0}
            ],
            credit: 3750,
            hide_patent?: false,
            level: 1,
            patent: :shipyard_2,
            production: 750
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 26.25},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 6.0},
              %Core.Bonus{from: :direct, to: :sys_corvette_lvl, type: :add, value: 6.0}
            ],
            credit: 9062,
            hide_patent?: true,
            level: 2,
            patent: :infra_orbital_2,
            production: 480
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 37.5},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 9.0},
              %Core.Bonus{from: :direct, to: :sys_corvette_lvl, type: :add, value: 9.0}
            ],
            credit: 14375,
            hide_patent?: true,
            level: 3,
            patent: :infra_orbital_3,
            production: 1440
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 48.75},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 12.0},
              %Core.Bonus{from: :direct, to: :sys_corvette_lvl, type: :add, value: 12.0}
            ],
            credit: 19687,
            hide_patent?: true,
            level: 4,
            patent: :infra_orbital_4,
            production: 3840
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 60.0},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 15.0},
              %Core.Bonus{from: :direct, to: :sys_corvette_lvl, type: :add, value: 15.0}
            ],
            credit: 25000,
            hide_patent?: true,
            level: 5,
            patent: :infra_orbital_5,
            production: 9600
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
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 20.0},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 4.0},
              %Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 2.0},
              %Core.Bonus{from: :direct, to: :sys_frigate_lvl, type: :add, value: 3.0}
            ],
            credit: 10000,
            hide_patent?: false,
            level: 1,
            patent: :shipyard_3,
            production: 1200
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 35.0},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 8.0},
              %Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 4.0},
              %Core.Bonus{from: :direct, to: :sys_frigate_lvl, type: :add, value: 6.0}
            ],
            credit: 23125,
            hide_patent?: true,
            level: 2,
            patent: :infra_orbital_2,
            production: 880
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 50.0},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 12.0},
              %Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 6.0},
              %Core.Bonus{from: :direct, to: :sys_frigate_lvl, type: :add, value: 9.0}
            ],
            credit: 36250,
            hide_patent?: true,
            level: 3,
            patent: :infra_orbital_3,
            production: 2640
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 65.0},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 16.0},
              %Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 8.0},
              %Core.Bonus{from: :direct, to: :sys_frigate_lvl, type: :add, value: 12.0}
            ],
            credit: 49375,
            hide_patent?: true,
            level: 4,
            patent: :infra_orbital_4,
            production: 7040
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 80.0},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 20.0},
              %Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_frigate_lvl, type: :add, value: 15.0}
            ],
            credit: 62500,
            hide_patent?: true,
            level: 5,
            patent: :infra_orbital_5,
            production: 17600
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
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 25.0},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 5.0},
              %Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 3.0},
              %Core.Bonus{from: :direct, to: :sys_capital_lvl, type: :add, value: 3.0}
            ],
            credit: 25000,
            hide_patent?: false,
            level: 1,
            patent: :shipyard_4,
            production: 2500
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 43.75},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 6.0},
              %Core.Bonus{from: :direct, to: :sys_capital_lvl, type: :add, value: 6.0}
            ],
            credit: 45625,
            hide_patent?: true,
            level: 2,
            patent: :infra_orbital_2,
            production: 1760
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 62.5},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 15.0},
              %Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 9.0},
              %Core.Bonus{from: :direct, to: :sys_capital_lvl, type: :add, value: 9.0}
            ],
            credit: 66250,
            hide_patent?: true,
            level: 3,
            patent: :infra_orbital_3,
            production: 5280
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 81.25},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 20.0},
              %Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 12.0},
              %Core.Bonus{from: :direct, to: :sys_capital_lvl, type: :add, value: 12.0}
            ],
            credit: 86875,
            hide_patent?: true,
            level: 4,
            patent: :infra_orbital_4,
            production: 14080
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 100.0},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 25.0},
              %Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 15.0},
              %Core.Bonus{from: :direct, to: :sys_capital_lvl, type: :add, value: 15.0}
            ],
            credit: 107_500,
            hide_patent?: true,
            level: 5,
            patent: :infra_orbital_5,
            production: 35200
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
              %Core.Bonus{from: :direct, to: :sys_fighter_lvl, type: :add, value: 6.0},
              %Core.Bonus{from: :direct, to: :sys_corvette_lvl, type: :add, value: 6.0},
              %Core.Bonus{from: :direct, to: :sys_frigate_lvl, type: :add, value: 6.0},
              %Core.Bonus{from: :direct, to: :sys_capital_lvl, type: :add, value: 6.0}
            ],
            credit: 4875,
            hide_patent?: false,
            level: 1,
            patent: :dome_academy,
            production: 1000
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_fighter_lvl, type: :add, value: 12.0},
              %Core.Bonus{from: :direct, to: :sys_corvette_lvl, type: :add, value: 12.0},
              %Core.Bonus{from: :direct, to: :sys_frigate_lvl, type: :add, value: 12.0},
              %Core.Bonus{from: :direct, to: :sys_capital_lvl, type: :add, value: 12.0}
            ],
            credit: 10400,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 2600
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_fighter_lvl, type: :add, value: 18.0},
              %Core.Bonus{from: :direct, to: :sys_corvette_lvl, type: :add, value: 18.0},
              %Core.Bonus{from: :direct, to: :sys_frigate_lvl, type: :add, value: 18.0},
              %Core.Bonus{from: :direct, to: :sys_capital_lvl, type: :add, value: 18.0}
            ],
            credit: 16900,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 5200
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_fighter_lvl, type: :add, value: 24.0},
              %Core.Bonus{from: :direct, to: :sys_corvette_lvl, type: :add, value: 24.0},
              %Core.Bonus{from: :direct, to: :sys_frigate_lvl, type: :add, value: 24.0},
              %Core.Bonus{from: :direct, to: :sys_capital_lvl, type: :add, value: 24.0}
            ],
            credit: 24375,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 10400
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_fighter_lvl, type: :add, value: 30.0},
              %Core.Bonus{from: :direct, to: :sys_corvette_lvl, type: :add, value: 30.0},
              %Core.Bonus{from: :direct, to: :sys_frigate_lvl, type: :add, value: 30.0},
              %Core.Bonus{from: :direct, to: :sys_capital_lvl, type: :add, value: 30.0}
            ],
            credit: 32500,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 20800
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
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_radar, type: :add, value: 0.5},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 4.0},
              %Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 5.0}
            ],
            credit: 1250,
            hide_patent?: false,
            level: 1,
            patent: :orbital_radar,
            production: 360
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_radar, type: :add, value: 1.25},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 8.0},
              %Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 8.75}
            ],
            credit: 2640,
            hide_patent?: true,
            level: 2,
            patent: :infra_orbital_2,
            production: 240
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_radar, type: :add, value: 2.0},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 12.0},
              %Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 12.5}
            ],
            credit: 4290,
            hide_patent?: true,
            level: 3,
            patent: :infra_orbital_3,
            production: 720
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_radar, type: :add, value: 2.75},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 16.0},
              %Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 16.25}
            ],
            credit: 6187,
            hide_patent?: true,
            level: 4,
            patent: :infra_orbital_4,
            production: 1920
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_radar, type: :add, value: 3.5},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 20.0},
              %Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 20.0}
            ],
            credit: 8250,
            hide_patent?: true,
            level: 5,
            patent: :infra_orbital_5,
            production: 4800
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
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 30.0},
              %Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 30.0}
            ],
            credit: 4690,
            hide_patent?: false,
            level: 1,
            patent: :open_intel,
            production: 3500
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 60.0},
              %Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 60.0}
            ],
            credit: 10000,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 3000
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 90.0},
              %Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 90.0}
            ],
            credit: 16250,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 6000
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 120.0},
              %Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 120.0}
            ],
            credit: 23437,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 12000
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 150.0},
              %Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 150.0}
            ],
            credit: 31250,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 24000
          }
        ],
        limitation: :unique_system,
        outputs: [:defense],
        type: :normal,
        workforce: 5
      },
      %Data.Game.Building{
        biome: :open,
        display: :defense,
        illustration: "removecontact_open.jpg",
        key: :removecontact_open,
        levels: [
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 20.0}],
            credit: 1200,
            hide_patent?: false,
            level: 1,
            patent: :infra_open_2,
            production: 10000
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 40.0}],
            credit: 2560,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 360
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 60.0}],
            credit: 4160,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 3600
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 80.0}],
            credit: 6000,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 7920
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 100.0}],
            credit: 8000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 14400
          }
        ],
        limitation: :unique_body,
        outputs: [:defense],
        type: :normal,
        workforce: 2
      },
      %Data.Game.Building{
        biome: :dome,
        display: :defense,
        illustration: "removecontact_dome.jpg",
        key: :removecontact_dome,
        levels: [
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 18.0}],
            credit: 1010,
            hide_patent?: false,
            level: 1,
            patent: :dome_academy,
            production: 250
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 36.0}],
            credit: 2160,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 300
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 54.0}],
            credit: 3510,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 3000
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 72.0}],
            credit: 5062,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 6600
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 90.0}],
            credit: 6750,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 12000
          }
        ],
        limitation: :none,
        outputs: [:defense],
        type: :normal,
        workforce: 1
      },
      %Data.Game.Building{
        biome: :gate,
        display: :infrastructure,
        illustration: "default.jpg",
        key: :hypergate,
        levels: [
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_mobility, type: :add, value: 16.0}],
            credit: 207_750,
            hide_patent?: false,
            level: 1,
            patent: :orbital_hypergate,
            production: 18000
          }
        ],
        limitation: :unique_system,
        outputs: [],
        type: :infrastructure,
        workforce: 10
      }
    ]
  end
end
