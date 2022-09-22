# credo:disable-for-this-file Credo.Check.Readability.LargeNumbers

defmodule Data.Game.Building.Content.Slow do
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
            credit: 8400,
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
            credit: 19712,
            hide_patent?: false,
            level: 2,
            patent: :infra_open_2,
            production: 900
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 6.0}
            ],
            credit: 32032,
            hide_patent?: false,
            level: 3,
            patent: :infra_open_3,
            production: 5400
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 8.0}
            ],
            credit: 46200,
            hide_patent?: false,
            level: 4,
            patent: :infra_open_4,
            production: 10800
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 10.0}
            ],
            credit: 61600,
            hide_patent?: false,
            level: 5,
            patent: :infra_open_5,
            production: 18000
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
            credit: 9000,
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
            credit: 21120,
            hide_patent?: false,
            level: 2,
            patent: :infra_dome_2,
            production: 990
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 6.0}
            ],
            credit: 34320,
            hide_patent?: false,
            level: 3,
            patent: :infra_dome_3,
            production: 5940
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 8.0}
            ],
            credit: 49500,
            hide_patent?: false,
            level: 4,
            patent: :infra_dome_4,
            production: 11880
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 10.0}
            ],
            credit: 66000,
            hide_patent?: false,
            level: 5,
            patent: :infra_dome_5,
            production: 19800
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
            credit: 1950,
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
            credit: 4576,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 900
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 6.3},
              %Core.Bonus{from: :body_pop, to: :sys_happiness, type: :add, value: -0.15}
            ],
            credit: 7436,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 5400
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 9.1},
              %Core.Bonus{from: :body_pop, to: :sys_happiness, type: :add, value: -0.2}
            ],
            credit: 10725,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 10800
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 14.0},
              %Core.Bonus{from: :body_pop, to: :sys_happiness, type: :add, value: -0.25}
            ],
            credit: 14300,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 18000
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
            credit: 3900,
            hide_patent?: false,
            level: 1,
            patent: :orbital_prod,
            production: 300
          },
          %{
            bonus: [%Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 4.8}],
            credit: 9152,
            hide_patent?: true,
            level: 2,
            patent: :infra_orbital_2,
            production: 1125
          },
          %{
            bonus: [%Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 7.8}],
            credit: 14872,
            hide_patent?: true,
            level: 3,
            patent: :infra_orbital_3,
            production: 6750
          },
          %{
            bonus: [%Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 11.25}],
            credit: 21450,
            hide_patent?: true,
            level: 4,
            patent: :infra_orbital_4,
            production: 13500
          },
          %{
            bonus: [%Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 15.0}],
            credit: 28600,
            hide_patent?: true,
            level: 5,
            patent: :infra_orbital_5,
            production: 22500
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
            credit: 1950,
            hide_patent?: false,
            level: 1,
            patent: nil,
            production: 30
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 3.25}],
            credit: 4576,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 225
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 3.5}],
            credit: 7436,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 1350
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 3.75}],
            credit: 10725,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 2700
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 4.0}],
            credit: 14300,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 4500
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
            credit: 3450,
            hide_patent?: false,
            level: 1,
            patent: :dome_pop,
            production: 200
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 3.75}],
            credit: 8096,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 900
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 4.5}],
            credit: 13156,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 5400
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 5.25}],
            credit: 18975,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 10800
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 6.0}],
            credit: 25300,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 18000
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
            credit: 4500,
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
            credit: 10560,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 1125
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 7.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -3.0}
            ],
            credit: 17160,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 6750
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 8.5},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -4.0}
            ],
            credit: 24750,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 13500
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -5.0}
            ],
            credit: 33000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 22500
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
            credit: 7500,
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
            credit: 17600,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 3375
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 4.0},
              %Core.Bonus{from: :body_act, to: :sys_credit, type: :add, value: 20.8}
            ],
            credit: 28600,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 20250
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 4.5},
              %Core.Bonus{from: :body_act, to: :sys_credit, type: :add, value: 30.0}
            ],
            credit: 41250,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 40500
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_habitation, type: :add, value: 5.0},
              %Core.Bonus{from: :body_act, to: :sys_credit, type: :add, value: 40.0}
            ],
            credit: 55000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 67500
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
            credit: 6000,
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
            credit: 14080,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 2475
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 6.75},
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 15.6},
              %Core.Bonus{from: :body_pop, to: :sys_happiness, type: :add, value: -0.15}
            ],
            credit: 22880,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 24750
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 9.75},
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 22.5},
              %Core.Bonus{from: :body_pop, to: :sys_happiness, type: :add, value: -0.2}
            ],
            credit: 33000,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 54450
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 15.0},
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 30.0},
              %Core.Bonus{from: :body_pop, to: :sys_happiness, type: :add, value: -0.25}
            ],
            credit: 44000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 99000
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
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 8.0}
            ],
            credit: 2000,
            hide_patent?: false,
            level: 1,
            patent: :orbital_credit,
            production: 120
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 1.8},
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 11.0}
            ],
            credit: 7040,
            hide_patent?: true,
            level: 2,
            patent: :infra_orbital_2,
            production: 1000
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 2.4},
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 14.0}
            ],
            credit: 11440,
            hide_patent?: true,
            level: 3,
            patent: :infra_orbital_3,
            production: 10000
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 2.7},
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 17.0}
            ],
            credit: 16500,
            hide_patent?: true,
            level: 4,
            patent: :infra_orbital_4,
            production: 22000
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 3.0},
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 20.0}
            ],
            credit: 22000,
            hide_patent?: true,
            level: 5,
            patent: :infra_orbital_5,
            production: 40000
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
              %Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 3.0}
            ],
            credit: 180_000,
            hide_patent?: false,
            level: 1,
            patent: :dome_industries,
            production: 30000
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 12.0},
              %Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 7.5}
            ],
            credit: 300_000,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 52500
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 18.0},
              %Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 12.0}
            ],
            credit: 420_000,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 105_000
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 26.0},
              %Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 19.5}
            ],
            credit: 540_000,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 210_000
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 40.0},
              %Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 30.0}
            ],
            credit: 660_000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 420_000
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
            credit: 70000,
            hide_patent?: false,
            level: 1,
            patent: :open_lift,
            production: 4000
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 12.0},
              %Core.Bonus{from: :body_ind, to: :sys_mobility, type: :add, value: 2.4}
            ],
            credit: 123_200,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 2820
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 18.0},
              %Core.Bonus{from: :body_ind, to: :sys_mobility, type: :add, value: 3.6}
            ],
            credit: 200_200,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 16920
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 26.0},
              %Core.Bonus{from: :body_ind, to: :sys_mobility, type: :add, value: 5.2}
            ],
            credit: 288_750,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 33840
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_credit, type: :add, value: 40.0},
              %Core.Bonus{from: :body_ind, to: :sys_mobility, type: :add, value: 8.0}
            ],
            credit: 385_000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 56400
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
            credit: 22500,
            hide_patent?: false,
            level: 1,
            patent: :dome_mobility,
            production: 1500
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 1.5},
              %Core.Bonus{from: :body_ind, to: :sys_mobility, type: :add, value: 1.8}
            ],
            credit: 52800,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 3040
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 2.4},
              %Core.Bonus{from: :body_ind, to: :sys_mobility, type: :add, value: 2.7}
            ],
            credit: 85800,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 9120
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 3.9},
              %Core.Bonus{from: :body_ind, to: :sys_mobility, type: :add, value: 3.9}
            ],
            credit: 123_750,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 24320
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_ind, to: :sys_production, type: :add, value: 6.0},
              %Core.Bonus{from: :body_ind, to: :sys_mobility, type: :add, value: 6.0}
            ],
            credit: 165_000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 60800
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
            credit: 1500,
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
            credit: 3520,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 337
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_technology, type: :add, value: 3.0},
              %Core.Bonus{from: :body_pop, to: :sys_technology, type: :add, value: 0.38}
            ],
            credit: 5720,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 3375
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_technology, type: :add, value: 3.0},
              %Core.Bonus{from: :body_pop, to: :sys_technology, type: :add, value: 0.49}
            ],
            credit: 8250,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 7425
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_technology, type: :add, value: 3.0},
              %Core.Bonus{from: :body_pop, to: :sys_technology, type: :add, value: 0.6}
            ],
            credit: 11000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 13500
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
            credit: 72000,
            hide_patent?: false,
            level: 1,
            patent: :open_research,
            production: 15000
          },
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 4.5}],
            credit: 153_000,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 37500
          },
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 6.75}],
            credit: 234_000,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 75000
          },
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 9.75}],
            credit: 315_000,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 150_000
          },
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 15.0}],
            credit: 396_000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 300_000
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
            credit: 3750,
            hide_patent?: false,
            level: 1,
            patent: :infra_dome_1,
            production: 250
          },
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 1.8}],
            credit: 8800,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 1575
          },
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 2.7}],
            credit: 14300,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 15750
          },
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 3.9}],
            credit: 20625,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 34650
          },
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 6.0}],
            credit: 27500,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 63000
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
            credit: 6000,
            hide_patent?: false,
            level: 1,
            patent: :orbital_research,
            production: 150
          },
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 1.2}],
            credit: 14080,
            hide_patent?: true,
            level: 2,
            patent: :infra_orbital_2,
            production: 900
          },
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 1.8}],
            credit: 22880,
            hide_patent?: true,
            level: 3,
            patent: :infra_orbital_3,
            production: 9000
          },
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 2.6}],
            credit: 33000,
            hide_patent?: true,
            level: 4,
            patent: :infra_orbital_4,
            production: 19800
          },
          %{
            bonus: [%Core.Bonus{from: :body_tec, to: :sys_technology, type: :add, value: 4.0}],
            credit: 44000,
            hide_patent?: true,
            level: 5,
            patent: :infra_orbital_5,
            production: 36000
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
            credit: 1500,
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
            credit: 3520,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 450
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_ideology, type: :add, value: 3.0},
              %Core.Bonus{from: :body_pop, to: :sys_ideology, type: :add, value: 0.38}
            ],
            credit: 5720,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 4500
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_ideology, type: :add, value: 3.0},
              %Core.Bonus{from: :body_pop, to: :sys_ideology, type: :add, value: 0.49}
            ],
            credit: 8250,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 9900
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_ideology, type: :add, value: 3.0},
              %Core.Bonus{from: :body_pop, to: :sys_ideology, type: :add, value: 0.6}
            ],
            credit: 11000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 18000
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
            credit: 3000,
            hide_patent?: false,
            level: 1,
            patent: :dome_happiness,
            production: 2000
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_pop, to: :sys_ideology, type: :add, value: 0.45},
              %Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 0.8}
            ],
            credit: 7040,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 6500
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_pop, to: :sys_ideology, type: :add, value: 0.68},
              %Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 1.2}
            ],
            credit: 11440,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 19500
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_pop, to: :sys_ideology, type: :add, value: 0.98},
              %Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 1.6}
            ],
            credit: 16500,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 52000
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_pop, to: :sys_ideology, type: :add, value: 1.5},
              %Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 2.0}
            ],
            credit: 22000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 130_000
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
            credit: 15000,
            hide_patent?: false,
            level: 1,
            patent: :open_ideo,
            production: 1200
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 3.0},
              %Core.Bonus{from: :direct, to: :sys_ideology, type: :add, value: 7.5}
            ],
            credit: 35200,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 4365
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 4.5},
              %Core.Bonus{from: :direct, to: :sys_ideology, type: :add, value: 12.0}
            ],
            credit: 57200,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 13095
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 6.5},
              %Core.Bonus{from: :direct, to: :sys_ideology, type: :add, value: 19.5}
            ],
            credit: 82500,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 34920
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_ideology, type: :add, value: 30.0}
            ],
            credit: 110_000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 87300
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
            credit: 160_000,
            hide_patent?: false,
            level: 1,
            patent: :dome_ideo,
            production: 20000
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 9.0},
              %Core.Bonus{from: :sys_pop, to: :sys_ideology, type: :add, value: 0.5}
            ],
            credit: 235_500,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 50000
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 13.5},
              %Core.Bonus{from: :sys_pop, to: :sys_ideology, type: :add, value: 0.8}
            ],
            credit: 311_000,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 100_000
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 19.5},
              %Core.Bonus{from: :sys_pop, to: :sys_ideology, type: :add, value: 1.3}
            ],
            credit: 386_500,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 200_000
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 30.0},
              %Core.Bonus{from: :sys_pop, to: :sys_ideology, type: :add, value: 2.0}
            ],
            credit: 462_000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 400_000
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
            credit: 50000,
            hide_patent?: false,
            level: 1,
            patent: :open_island,
            production: 2200
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_act, to: :sys_ideology, type: :add, value: 2.56},
              %Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 2.4},
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 2.0}
            ],
            credit: 106_250,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 8100
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_act, to: :sys_ideology, type: :add, value: 4.16},
              %Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 3.6},
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 3.0}
            ],
            credit: 162_500,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 24300
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_act, to: :sys_ideology, type: :add, value: 6.0},
              %Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 5.2},
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 4.0}
            ],
            credit: 218_750,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 64800
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_act, to: :sys_ideology, type: :add, value: 8.0},
              %Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 8.0},
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 5.0}
            ],
            credit: 275_000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 162_000
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
            credit: 4000,
            hide_patent?: false,
            level: 1,
            patent: :open_credit,
            production: 200
          },
          %{
            bonus: [%Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 4.0}],
            credit: 14080,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 1350
          },
          %{
            bonus: [%Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 6.0}],
            credit: 22880,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 13500
          },
          %{
            bonus: [%Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 8.0}],
            credit: 33000,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 29700
          },
          %{
            bonus: [%Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 10.0}],
            credit: 44000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 54000
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
            credit: 8000,
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
            credit: 17600,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 1012
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 3.6},
              %Core.Bonus{from: :direct, to: :sys_technology, type: :add, value: 3.6}
            ],
            credit: 28600,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 10125
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 4.8},
              %Core.Bonus{from: :direct, to: :sys_technology, type: :add, value: 4.8}
            ],
            credit: 41250,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 22275
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_pop, to: :sys_credit, type: :add, value: 6.0},
              %Core.Bonus{from: :direct, to: :sys_technology, type: :add, value: 6.0}
            ],
            credit: 55000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 40500
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
            credit: 140_000,
            hide_patent?: false,
            level: 1,
            patent: :open_mobility,
            production: 20000
          },
          %{
            bonus: [
              %Core.Bonus{from: :sys_mobility, to: :sys_credit, type: :add, value: 4.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -12.8}
            ],
            credit: 212_250,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 52312
          },
          %{
            bonus: [
              %Core.Bonus{from: :sys_mobility, to: :sys_credit, type: :add, value: 6.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -19.2}
            ],
            credit: 284_500,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 104_625
          },
          %{
            bonus: [
              %Core.Bonus{from: :sys_mobility, to: :sys_credit, type: :add, value: 8.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -25.6}
            ],
            credit: 356_750,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 209_250
          },
          %{
            bonus: [
              %Core.Bonus{from: :sys_mobility, to: :sys_credit, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -32.0}
            ],
            credit: 429_000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 418_500
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
            credit: 40000,
            hide_patent?: false,
            level: 1,
            patent: :orbital_mobility,
            production: 2500
          },
          %{
            bonus: [
              %Core.Bonus{from: :sys_mobility, to: :sys_credit, type: :add, value: 2.4},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -7.2}
            ],
            credit: 74000,
            hide_patent?: true,
            level: 2,
            patent: :infra_orbital_2,
            production: 9000
          },
          %{
            bonus: [
              %Core.Bonus{from: :sys_mobility, to: :sys_credit, type: :add, value: 3.6},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -10.8}
            ],
            credit: 108_000,
            hide_patent?: true,
            level: 3,
            patent: :infra_orbital_3,
            production: 54000
          },
          %{
            bonus: [
              %Core.Bonus{from: :sys_mobility, to: :sys_credit, type: :add, value: 4.8},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -14.4}
            ],
            credit: 142_000,
            hide_patent?: true,
            level: 4,
            patent: :infra_orbital_4,
            production: 108_000
          },
          %{
            bonus: [
              %Core.Bonus{from: :sys_mobility, to: :sys_credit, type: :add, value: 6.0},
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: -18.0}
            ],
            credit: 176_000,
            hide_patent?: true,
            level: 5,
            patent: :infra_orbital_5,
            production: 180_000
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
            credit: 9000,
            hide_patent?: false,
            level: 1,
            patent: :dome_mobility,
            production: 1400
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_mobility, type: :add, value: 3.2},
              %Core.Bonus{from: :body_pop, to: :sys_production, type: :add, value: 0.8}
            ],
            credit: 21120,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 2780
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_mobility, type: :add, value: 4.8},
              %Core.Bonus{from: :body_pop, to: :sys_production, type: :add, value: 1.2}
            ],
            credit: 34320,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 8340
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_mobility, type: :add, value: 6.4},
              %Core.Bonus{from: :body_pop, to: :sys_production, type: :add, value: 1.6}
            ],
            credit: 49500,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 22240
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_mobility, type: :add, value: 8.0},
              %Core.Bonus{from: :body_pop, to: :sys_production, type: :add, value: 2.0}
            ],
            credit: 66000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 55600
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
            credit: 20000,
            hide_patent?: false,
            level: 1,
            patent: :orbital_mobility,
            production: 1600
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_mobility, type: :add, value: 3.0},
              %Core.Bonus{from: :direct, to: :sys_credit, type: :add, value: 40.0}
            ],
            credit: 35200,
            hide_patent?: true,
            level: 2,
            patent: :infra_orbital_2,
            production: 3010
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_mobility, type: :add, value: 4.5},
              %Core.Bonus{from: :direct, to: :sys_credit, type: :add, value: 60.0}
            ],
            credit: 57200,
            hide_patent?: true,
            level: 3,
            patent: :infra_orbital_3,
            production: 18060
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_mobility, type: :add, value: 6.0},
              %Core.Bonus{from: :direct, to: :sys_credit, type: :add, value: 80.0}
            ],
            credit: 82500,
            hide_patent?: true,
            level: 4,
            patent: :infra_orbital_4,
            production: 36120
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_mobility, type: :add, value: 7.5},
              %Core.Bonus{from: :direct, to: :sys_credit, type: :add, value: 100.0}
            ],
            credit: 110_000,
            hide_patent?: true,
            level: 5,
            patent: :infra_orbital_5,
            production: 60200
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
            credit: 19500,
            hide_patent?: false,
            level: 1,
            patent: :dome_defense_2,
            production: 5000
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 4.0},
              %Core.Bonus{from: :sys_defense, to: :sys_defense, type: :add, value: 0.4}
            ],
            credit: 45760,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 13500
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 6.0},
              %Core.Bonus{from: :sys_defense, to: :sys_defense, type: :add, value: 0.6}
            ],
            credit: 74360,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 27000
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 8.0},
              %Core.Bonus{from: :sys_defense, to: :sys_defense, type: :add, value: 0.8}
            ],
            credit: 107_250,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 54000
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 10.0},
              %Core.Bonus{from: :sys_defense, to: :sys_defense, type: :add, value: 1.0}
            ],
            credit: 143_000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 108_000
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
            credit: 11250,
            hide_patent?: false,
            level: 1,
            patent: :open_defense,
            production: 1000
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 9.6}],
            credit: 26400,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 3600
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 14.4}],
            credit: 42900,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 10800
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 19.2}],
            credit: 61875,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 28800
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 24.0}],
            credit: 82500,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 72000
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
            credit: 9750,
            hide_patent?: false,
            level: 1,
            patent: :dome_defense_1,
            production: 800
          },
          %{
            bonus: [%Core.Bonus{from: :body_pop, to: :sys_defense, type: :add, value: 0.8}],
            credit: 22880,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 2790
          },
          %{
            bonus: [%Core.Bonus{from: :body_pop, to: :sys_defense, type: :add, value: 1.2}],
            credit: 37180,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 8370
          },
          %{
            bonus: [%Core.Bonus{from: :body_pop, to: :sys_defense, type: :add, value: 1.6}],
            credit: 53625,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 22320
          },
          %{
            bonus: [%Core.Bonus{from: :body_pop, to: :sys_defense, type: :add, value: 2.0}],
            credit: 71500,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 55800
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
            credit: 3750,
            hide_patent?: false,
            level: 1,
            patent: :orbital_defense,
            production: 100
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 4.75}],
            credit: 8800,
            hide_patent?: true,
            level: 2,
            patent: :infra_orbital_2,
            production: 225
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 6.5}],
            credit: 14300,
            hide_patent?: true,
            level: 3,
            patent: :infra_orbital_3,
            production: 1350
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 8.25}],
            credit: 20625,
            hide_patent?: true,
            level: 4,
            patent: :infra_orbital_4,
            production: 2700
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 10.0}],
            credit: 27500,
            hide_patent?: true,
            level: 5,
            patent: :infra_orbital_5,
            production: 4500
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
            credit: 64000,
            hide_patent?: false,
            level: 1,
            patent: :open_happiness,
            production: 12000
          },
          %{
            bonus: [%Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 10.0}],
            credit: 95700,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 31500
          },
          %{
            bonus: [%Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 15.0}],
            credit: 143_550,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 63000
          },
          %{
            bonus: [%Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 20.0}],
            credit: 207_350,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 126_000
          },
          %{
            bonus: [%Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 25.0}],
            credit: 319_000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 252_000
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
            credit: 20250,
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
            credit: 47520,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 2160
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 7.2},
              %Core.Bonus{from: :body_act, to: :sys_technology, type: :add, value: 1.8}
            ],
            credit: 77220,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 6480
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 9.6},
              %Core.Bonus{from: :body_act, to: :sys_technology, type: :add, value: 2.4}
            ],
            credit: 111_375,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 17280
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 12.0},
              %Core.Bonus{from: :body_act, to: :sys_technology, type: :add, value: 3.0}
            ],
            credit: 148_500,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 43200
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
            credit: 9900,
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
            credit: 23232,
            hide_patent?: true,
            level: 2,
            patent: :infra_orbital_2,
            production: 2880
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 5.0},
              %Core.Bonus{from: :body_act, to: :sys_credit, type: :add, value: 5.0}
            ],
            credit: 37752,
            hide_patent?: true,
            level: 3,
            patent: :infra_orbital_3,
            production: 8640
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 6.5},
              %Core.Bonus{from: :body_act, to: :sys_credit, type: :add, value: 6.5}
            ],
            credit: 54450,
            hide_patent?: true,
            level: 4,
            patent: :infra_orbital_4,
            production: 23040
          },
          %{
            bonus: [
              %Core.Bonus{from: :body_act, to: :sys_happiness, type: :add, value: 8.0},
              %Core.Bonus{from: :body_act, to: :sys_credit, type: :add, value: 8.0}
            ],
            credit: 72600,
            hide_patent?: true,
            level: 5,
            patent: :infra_orbital_5,
            production: 57600
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
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 6.0},
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 2.0}
            ],
            credit: 3300,
            hide_patent?: false,
            level: 1,
            patent: :orbital_defense,
            production: 200
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 12.0},
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 4.0}
            ],
            credit: 7744,
            hide_patent?: true,
            level: 2,
            patent: :infra_orbital_2,
            production: 750
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 18.0},
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 6.0}
            ],
            credit: 12584,
            hide_patent?: true,
            level: 3,
            patent: :infra_orbital_3,
            production: 7500
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 24.0},
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 8.0}
            ],
            credit: 18150,
            hide_patent?: true,
            level: 4,
            patent: :infra_orbital_4,
            production: 16500
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_happiness, type: :add, value: 30.0},
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 10.0}
            ],
            credit: 24200,
            hide_patent?: true,
            level: 5,
            patent: :infra_orbital_5,
            production: 30000
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
            credit: 10500,
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
            credit: 27125,
            hide_patent?: true,
            level: 2,
            patent: :infra_orbital_2,
            production: 1440
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 25.0},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 6.0},
              %Core.Bonus{from: :direct, to: :sys_fighter_lvl, type: :add, value: 9.0}
            ],
            credit: 43750,
            hide_patent?: true,
            level: 3,
            patent: :infra_orbital_3,
            production: 4320
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 32.5},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 8.0},
              %Core.Bonus{from: :direct, to: :sys_fighter_lvl, type: :add, value: 12.0}
            ],
            credit: 60375,
            hide_patent?: true,
            level: 4,
            patent: :infra_orbital_4,
            production: 11520
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 40.0},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_fighter_lvl, type: :add, value: 15.0}
            ],
            credit: 77000,
            hide_patent?: true,
            level: 5,
            patent: :infra_orbital_5,
            production: 28800
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
            credit: 15000,
            hide_patent?: false,
            level: 1,
            patent: :shipyard_2,
            production: 800
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 26.25},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 6.0},
              %Core.Bonus{from: :direct, to: :sys_corvette_lvl, type: :add, value: 6.0}
            ],
            credit: 38750,
            hide_patent?: true,
            level: 2,
            patent: :infra_orbital_2,
            production: 2880
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 37.5},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 9.0},
              %Core.Bonus{from: :direct, to: :sys_corvette_lvl, type: :add, value: 9.0}
            ],
            credit: 62500,
            hide_patent?: true,
            level: 3,
            patent: :infra_orbital_3,
            production: 8640
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 48.75},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 12.0},
              %Core.Bonus{from: :direct, to: :sys_corvette_lvl, type: :add, value: 12.0}
            ],
            credit: 86250,
            hide_patent?: true,
            level: 4,
            patent: :infra_orbital_4,
            production: 23040
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 60.0},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 15.0},
              %Core.Bonus{from: :direct, to: :sys_corvette_lvl, type: :add, value: 15.0}
            ],
            credit: 110_000,
            hide_patent?: true,
            level: 5,
            patent: :infra_orbital_5,
            production: 57600
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
            credit: 40000,
            hide_patent?: false,
            level: 1,
            patent: :shipyard_3,
            production: 1500
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 35.0},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 8.0},
              %Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 4.0},
              %Core.Bonus{from: :direct, to: :sys_frigate_lvl, type: :add, value: 6.0}
            ],
            credit: 98750,
            hide_patent?: true,
            level: 2,
            patent: :infra_orbital_2,
            production: 5400
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 50.0},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 12.0},
              %Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 6.0},
              %Core.Bonus{from: :direct, to: :sys_frigate_lvl, type: :add, value: 9.0}
            ],
            credit: 157_500,
            hide_patent?: true,
            level: 3,
            patent: :infra_orbital_3,
            production: 16200
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 65.0},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 16.0},
              %Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 8.0},
              %Core.Bonus{from: :direct, to: :sys_frigate_lvl, type: :add, value: 12.0}
            ],
            credit: 216_250,
            hide_patent?: true,
            level: 4,
            patent: :infra_orbital_4,
            production: 43200
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 80.0},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 20.0},
              %Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_frigate_lvl, type: :add, value: 15.0}
            ],
            credit: 275_000,
            hide_patent?: true,
            level: 5,
            patent: :infra_orbital_5,
            production: 108_000
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
            credit: 100_000,
            hide_patent?: false,
            level: 1,
            patent: :shipyard_4,
            production: 3000
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 43.75},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 10.0},
              %Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 6.0},
              %Core.Bonus{from: :direct, to: :sys_capital_lvl, type: :add, value: 6.0}
            ],
            credit: 193_250,
            hide_patent?: true,
            level: 2,
            patent: :infra_orbital_2,
            production: 10800
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 62.5},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 15.0},
              %Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 9.0},
              %Core.Bonus{from: :direct, to: :sys_capital_lvl, type: :add, value: 9.0}
            ],
            credit: 286_500,
            hide_patent?: true,
            level: 3,
            patent: :infra_orbital_3,
            production: 32400
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 81.25},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 20.0},
              %Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 12.0},
              %Core.Bonus{from: :direct, to: :sys_capital_lvl, type: :add, value: 12.0}
            ],
            credit: 379_750,
            hide_patent?: true,
            level: 4,
            patent: :infra_orbital_4,
            production: 86400
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_production, type: :add, value: 100.0},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 25.0},
              %Core.Bonus{from: :direct, to: :sys_defense, type: :add, value: 15.0},
              %Core.Bonus{from: :direct, to: :sys_capital_lvl, type: :add, value: 15.0}
            ],
            credit: 473_000,
            hide_patent?: true,
            level: 5,
            patent: :infra_orbital_5,
            production: 216_000
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
            credit: 19500,
            hide_patent?: false,
            level: 1,
            patent: :dome_academy,
            production: 6000
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_fighter_lvl, type: :add, value: 12.0},
              %Core.Bonus{from: :direct, to: :sys_corvette_lvl, type: :add, value: 12.0},
              %Core.Bonus{from: :direct, to: :sys_frigate_lvl, type: :add, value: 12.0},
              %Core.Bonus{from: :direct, to: :sys_capital_lvl, type: :add, value: 12.0}
            ],
            credit: 45760,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 15750
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_fighter_lvl, type: :add, value: 18.0},
              %Core.Bonus{from: :direct, to: :sys_corvette_lvl, type: :add, value: 18.0},
              %Core.Bonus{from: :direct, to: :sys_frigate_lvl, type: :add, value: 18.0},
              %Core.Bonus{from: :direct, to: :sys_capital_lvl, type: :add, value: 18.0}
            ],
            credit: 74360,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 31500
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_fighter_lvl, type: :add, value: 24.0},
              %Core.Bonus{from: :direct, to: :sys_corvette_lvl, type: :add, value: 24.0},
              %Core.Bonus{from: :direct, to: :sys_frigate_lvl, type: :add, value: 24.0},
              %Core.Bonus{from: :direct, to: :sys_capital_lvl, type: :add, value: 24.0}
            ],
            credit: 107_250,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 63000
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_fighter_lvl, type: :add, value: 30.0},
              %Core.Bonus{from: :direct, to: :sys_corvette_lvl, type: :add, value: 30.0},
              %Core.Bonus{from: :direct, to: :sys_frigate_lvl, type: :add, value: 30.0},
              %Core.Bonus{from: :direct, to: :sys_capital_lvl, type: :add, value: 30.0}
            ],
            credit: 143_000,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 126_000
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
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 5.0},
              %Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 5.0}
            ],
            credit: 4950,
            hide_patent?: false,
            level: 1,
            patent: :orbital_radar,
            production: 360
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_radar, type: :add, value: 1.25},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 16.25},
              %Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 8.75}
            ],
            credit: 11616,
            hide_patent?: true,
            level: 2,
            patent: :infra_orbital_2,
            production: 1350
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_radar, type: :add, value: 2.0},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 27.5},
              %Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 12.5}
            ],
            credit: 18876,
            hide_patent?: true,
            level: 3,
            patent: :infra_orbital_3,
            production: 4050
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_radar, type: :add, value: 2.75},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 38.75},
              %Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 16.25}
            ],
            credit: 27225,
            hide_patent?: true,
            level: 4,
            patent: :infra_orbital_4,
            production: 10800
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_radar, type: :add, value: 3.5},
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 50.0},
              %Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 20.0}
            ],
            credit: 36300,
            hide_patent?: true,
            level: 5,
            patent: :infra_orbital_5,
            production: 27000
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
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 50.0},
              %Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 30.0}
            ],
            credit: 18750,
            hide_patent?: false,
            level: 1,
            patent: :open_intel,
            production: 7500
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 80.0},
              %Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 60.0}
            ],
            credit: 44000,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 16875
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 110.0},
              %Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 90.0}
            ],
            credit: 71500,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 33750
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 140.0},
              %Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 120.0}
            ],
            credit: 103_125,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 67500
          },
          %{
            bonus: [
              %Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 170.0},
              %Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 150.0}
            ],
            credit: 137_500,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 135_000
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
            bonus: [%Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 30.0}],
            credit: 4800,
            hide_patent?: false,
            level: 1,
            patent: :infra_open_2,
            production: 1500
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 50.0}],
            credit: 11264,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 2025
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 70.0}],
            credit: 18304,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 20250
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 90.0}],
            credit: 26400,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 44550
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_ci, type: :add, value: 110.0}],
            credit: 35200,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 81000
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
            bonus: [%Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 20.0}],
            credit: 4050,
            hide_patent?: false,
            level: 1,
            patent: :dome_defense_1,
            production: 250
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 40.0}],
            credit: 9504,
            hide_patent?: false,
            level: 2,
            patent: nil,
            production: 1687
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 60.0}],
            credit: 15444,
            hide_patent?: false,
            level: 3,
            patent: nil,
            production: 16875
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 80.0}],
            credit: 22275,
            hide_patent?: false,
            level: 4,
            patent: nil,
            production: 37125
          },
          %{
            bonus: [%Core.Bonus{from: :direct, to: :sys_remove_contact, type: :add, value: 100.0}],
            credit: 29700,
            hide_patent?: false,
            level: 5,
            patent: nil,
            production: 67500
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
            credit: 831_000,
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
