# credo:disable-for-this-file Credo.Check.Readability.LargeNumbers

defmodule Data.Game.Patent.Content.Fast do
  def data do
    [
      %Data.Game.Patent{
        ancestor: nil,
        class: :root,
        cost: 50,
        illustration: "citadel.jpg",
        info: nil,
        key: :citadel,
        type: :building,
        unlock: [%{key: :ideo_open, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :citadel,
        class: :economic,
        cost: 400,
        illustration: "infra_open_1.jpg",
        info: nil,
        key: :infra_open_1,
        type: :building,
        unlock: [
          %{key: :infra_open, level: 1, type: :building},
          %{key: :infra_dome, level: 1, type: :building},
          %{key: :mine_dome, level: 1, type: :building},
          %{key: :factory_orbital, level: 1, type: :building}
        ]
      },
      %Data.Game.Patent{
        ancestor: :infra_open_1,
        class: :economic,
        cost: 1200,
        illustration: "open_island.jpg",
        info: nil,
        key: :open_island,
        type: :building,
        unlock: [%{key: :ideo_credit_open, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :infra_open_1,
        class: :economic,
        cost: 1000,
        illustration: "dome_happiness.jpg",
        info: nil,
        key: :dome_happiness,
        type: :building,
        unlock: [
          %{key: :defense_local_orbital, level: 1, type: :building},
          %{key: :happy_pot_dome, level: 1, type: :building}
        ]
      },
      %Data.Game.Patent{
        ancestor: :dome_happiness,
        class: :economic,
        cost: 2000,
        illustration: "infra_dome_1.jpg",
        info: nil,
        key: :infra_dome_1,
        type: :building,
        unlock: [
          %{key: :hab_dome, level: 1, type: :building},
          %{key: :hab_open_rich, level: 1, type: :building}
        ]
      },
      %Data.Game.Patent{
        ancestor: :infra_dome_1,
        class: :economic,
        cost: 4500,
        illustration: "open_defense.jpg",
        info: nil,
        key: :open_defense,
        type: :building,
        unlock: [
          %{key: :defense_local_open, level: 1, type: :building},
          %{key: :defense_local_dome, level: 1, type: :building},
          %{key: :radar_orbital, level: 1, type: :building}
        ]
      },
      %Data.Game.Patent{
        ancestor: :open_defense,
        class: :economic,
        cost: 7000,
        illustration: "dome_defense_2.jpg",
        info: nil,
        key: :dome_defense_2,
        type: :building,
        unlock: [
          %{key: :defense_global_dome, level: 1, type: :building},
          %{key: :counterintelligence_open, level: 1, type: :building}
        ]
      },
      %Data.Game.Patent{
        ancestor: :infra_dome_1,
        class: :economic,
        cost: 4500,
        illustration: "open_research.jpg",
        info: nil,
        key: :open_research,
        type: :building,
        unlock: [
          %{key: :research_open, level: 1, type: :building},
          %{key: :happy_pot_orbital, level: 1, type: :building}
        ]
      },
      %Data.Game.Patent{
        ancestor: :open_research,
        class: :economic,
        cost: 7000,
        illustration: "open_happiness.jpg",
        info: nil,
        key: :open_happiness,
        type: :building,
        unlock: [%{key: :happy_pot_open, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :open_happiness,
        class: :economic,
        cost: 10000,
        illustration: "dome_ideo.jpg",
        info: nil,
        key: :dome_ideo,
        type: :building,
        unlock: [%{key: :monument_dome, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :dome_ideo,
        class: :economic,
        cost: 14000,
        illustration: "dome_industries.jpg",
        info: nil,
        key: :dome_industries,
        type: :building,
        unlock: [%{key: :high_factory_dome, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :infra_dome_1,
        class: :economic,
        cost: 4500,
        illustration: "open_credit.jpg",
        info: nil,
        key: :open_credit,
        type: :building,
        unlock: [
          %{key: :lift_open, level: 1, type: :building},
          %{key: :market_open, level: 1, type: :building}
        ]
      },
      %Data.Game.Patent{
        ancestor: :open_credit,
        class: :economic,
        cost: 7000,
        illustration: "dome_mobility.jpg",
        info: nil,
        key: :dome_mobility,
        type: :building,
        unlock: [
          %{key: :spatioport_dome, level: 1, type: :building},
          %{key: :spatioport_orbital, level: 1, type: :building}
        ]
      },
      %Data.Game.Patent{
        ancestor: :dome_mobility,
        class: :economic,
        cost: 12000,
        illustration: "open_mobility.jpg",
        info: nil,
        key: :open_mobility,
        type: :building,
        unlock: [%{key: :finance_open, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :infra_open_1,
        class: :economic,
        cost: 1200,
        illustration: "orbital_research.jpg",
        info: nil,
        key: :orbital_research,
        type: :building,
        unlock: [%{key: :research_orbital, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :citadel,
        class: :military,
        cost: 300,
        illustration: "shipyard_1.jpg",
        info: nil,
        key: :shipyard_1,
        type: :building,
        unlock: [
          %{key: :shipyard_1_orbital, level: 1, type: :building},
          %{key: :fighter_1, type: :ship}
        ]
      },
      %Data.Game.Patent{
        ancestor: :shipyard_1,
        class: :military,
        cost: 600,
        illustration: "fighter_1.jpg",
        info: nil,
        key: :fighter_2,
        type: :ship,
        unlock: [%{key: :fighter_2, type: :ship}]
      },
      %Data.Game.Patent{
        ancestor: :fighter_2,
        class: :military,
        cost: 800,
        illustration: "fighter_3.jpg",
        info: nil,
        key: :fighter_4,
        type: :ship,
        unlock: [%{key: :fighter_4, type: :ship}]
      },
      %Data.Game.Patent{
        ancestor: :shipyard_1,
        class: :military,
        cost: 600,
        illustration: "fighter_4.jpg",
        info: nil,
        key: :fighter_3,
        type: :ship,
        unlock: [%{key: :fighter_3, type: :ship}]
      },
      %Data.Game.Patent{
        ancestor: :shipyard_1,
        class: :military,
        cost: 800,
        illustration: "merge_fighter_1.jpg",
        info: :merge_fighter_1,
        key: :merge_fighter_1,
        type: :ship,
        unlock: []
      },
      %Data.Game.Patent{
        ancestor: :merge_fighter_1,
        class: :military,
        cost: 900,
        illustration: "shipyard_2.jpg",
        info: nil,
        key: :shipyard_2,
        type: :building,
        unlock: [%{key: :shipyard_2_orbital, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :shipyard_2,
        class: :military,
        cost: 1000,
        illustration: "merge_fighter_corvette.jpg",
        info: :merge_fighter_corvette,
        key: :merge_fighter_corvette,
        type: :ship,
        unlock: []
      },
      %Data.Game.Patent{
        ancestor: :merge_fighter_corvette,
        class: :military,
        cost: 2000,
        illustration: "shipyard_3.jpg",
        info: nil,
        key: :shipyard_3,
        type: :building,
        unlock: [
          %{key: :shipyard_3_orbital, level: 1, type: :building},
          %{key: :frigate_1, type: :ship}
        ]
      },
      %Data.Game.Patent{
        ancestor: :shipyard_3,
        class: :military,
        cost: 4000,
        illustration: "frigate_3.jpg",
        info: nil,
        key: :frigate_3,
        type: :ship,
        unlock: [%{key: :frigate_3, type: :ship}]
      },
      %Data.Game.Patent{
        ancestor: :frigate_3,
        class: :military,
        cost: 5000,
        illustration: "frigate_2.jpg",
        info: nil,
        key: :frigate_2,
        type: :ship,
        unlock: [%{key: :frigate_2, type: :ship}]
      },
      %Data.Game.Patent{
        ancestor: :shipyard_3,
        class: :military,
        cost: 4000,
        illustration: "frigate_4.jpg",
        info: nil,
        key: :frigate_4,
        type: :ship,
        unlock: [%{key: :frigate_4, type: :ship}]
      },
      %Data.Game.Patent{
        ancestor: :shipyard_3,
        class: :military,
        cost: 4500,
        illustration: "merge_fighter_3.jpg",
        info: :merge_fighter_3,
        key: :merge_fighter_3,
        type: :ship,
        unlock: []
      },
      %Data.Game.Patent{
        ancestor: :merge_fighter_3,
        class: :military,
        cost: 5000,
        illustration: "merge_corvette_2.jpg",
        info: :merge_corvette_2,
        key: :merge_corvette_2,
        type: :ship,
        unlock: []
      },
      %Data.Game.Patent{
        ancestor: :merge_corvette_2,
        class: :military,
        cost: 6500,
        illustration: "shipyard_4.jpg",
        info: nil,
        key: :shipyard_4,
        type: :building,
        unlock: [%{key: :shipyard_4_orbital, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :shipyard_4,
        class: :military,
        cost: 8000,
        illustration: "capital_1.jpg",
        info: nil,
        key: :capital_1,
        type: :ship,
        unlock: [%{key: :capital_1, type: :ship}]
      },
      %Data.Game.Patent{
        ancestor: :capital_1,
        class: :military,
        cost: 10000,
        illustration: "capital_2.jpg",
        info: nil,
        key: :capital_2,
        type: :ship,
        unlock: [%{key: :capital_2, type: :ship}]
      },
      %Data.Game.Patent{
        ancestor: :shipyard_4,
        class: :military,
        cost: 7500,
        illustration: "merge_frigate_1.jpg",
        info: :merge_frigate_1,
        key: :merge_frigate_1,
        type: :ship,
        unlock: []
      },
      %Data.Game.Patent{
        ancestor: :shipyard_4,
        class: :military,
        cost: 8000,
        illustration: "capital_3.jpg",
        info: nil,
        key: :capital_3,
        type: :ship,
        unlock: [%{key: :capital_3, type: :ship}]
      },
      %Data.Game.Patent{
        ancestor: :shipyard_2,
        class: :military,
        cost: 1000,
        illustration: "corvette_1.jpg",
        info: nil,
        key: :corvette_1,
        type: :ship,
        unlock: [%{key: :corvette_1, type: :ship}]
      },
      %Data.Game.Patent{
        ancestor: :shipyard_2,
        class: :military,
        cost: 1500,
        illustration: "corvette_2.jpg",
        info: nil,
        key: :corvette_2,
        type: :ship,
        unlock: [%{key: :corvette_2, type: :ship}]
      },
      %Data.Game.Patent{
        ancestor: :corvette_2,
        class: :military,
        cost: 4000,
        illustration: "corvette_3.jpg",
        info: nil,
        key: :corvette_3,
        type: :ship,
        unlock: [%{key: :corvette_3, type: :ship}]
      },
      %Data.Game.Patent{
        ancestor: :corvette_3,
        class: :military,
        cost: 2800,
        illustration: "dome_academy.jpg",
        info: nil,
        key: :dome_academy,
        type: :building,
        unlock: [%{key: :military_school_dome, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :citadel,
        class: :military,
        cost: 600,
        illustration: "transport_1.jpg",
        info: nil,
        key: :transport_1,
        type: :ship,
        unlock: [%{key: :transport_1, type: :ship}]
      },
      %Data.Game.Patent{
        ancestor: :transport_1,
        class: :military,
        cost: 4200,
        illustration: "transport_2.jpg",
        info: nil,
        key: :transport_2,
        type: :ship,
        unlock: [%{key: :transport_2, type: :ship}]
      }
    ]
  end
end
