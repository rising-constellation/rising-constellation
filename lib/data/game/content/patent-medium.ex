# credo:disable-for-this-file Credo.Check.Readability.LargeNumbers

defmodule Data.Game.Patent.Content.Medium do
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
        class: :open,
        cost: 50,
        illustration: "infra_open_1.jpg",
        info: nil,
        key: :infra_open_1,
        type: :building,
        unlock: [%{key: :infra_open, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :infra_open_1,
        class: :open,
        cost: 150,
        illustration: "open_industries.jpg",
        info: nil,
        key: :open_industries,
        type: :building,
        unlock: [
          %{key: :hab_open_poor, level: 1, type: :building},
          %{key: :factory_open, level: 1, type: :building}
        ]
      },
      %Data.Game.Patent{
        ancestor: :open_industries,
        class: :open,
        cost: 600,
        illustration: "open_research.jpg",
        info: nil,
        key: :open_research,
        type: :building,
        unlock: [%{key: :research_open, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :open_research,
        class: :open,
        cost: 3000,
        illustration: "open_intel.jpg",
        info: nil,
        key: :open_intel,
        type: :building,
        unlock: [%{key: :counterintelligence_open, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :infra_open_1,
        class: :open,
        cost: 50,
        illustration: "infra_open_1.jpg",
        info: :infra_open_2,
        key: :infra_open_2,
        type: :building,
        unlock: [
          %{key: :infra_open, level: 2, type: :building},
          %{key: :removecontact_open, level: 1, type: :building}
        ]
      },
      %Data.Game.Patent{
        ancestor: :infra_open_2,
        class: :open,
        cost: 200,
        illustration: "open_ideo.jpg",
        info: nil,
        key: :open_ideo,
        type: :building,
        unlock: [%{key: :monument_open, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :open_ideo,
        class: :open,
        cost: 300,
        illustration: "infra_open_1.jpg",
        info: :infra_open_3,
        key: :infra_open_3,
        type: :building,
        unlock: [%{key: :infra_open, level: 3, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :infra_open_3,
        class: :open,
        cost: 1500,
        illustration: "open_defense.jpg",
        info: nil,
        key: :open_defense,
        type: :building,
        unlock: [%{key: :defense_local_open, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :open_defense,
        class: :open,
        cost: 800,
        illustration: "infra_open_1.jpg",
        info: :infra_open_4,
        key: :infra_open_4,
        type: :building,
        unlock: [%{key: :infra_open, level: 4, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :infra_open_4,
        class: :open,
        cost: 2000,
        illustration: "infra_open_1.jpg",
        info: :infra_open_5,
        key: :infra_open_5,
        type: :building,
        unlock: [%{key: :infra_open, level: 5, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :infra_open_1,
        class: :open,
        cost: 350,
        illustration: "open_credit.jpg",
        info: nil,
        key: :open_credit,
        type: :building,
        unlock: [
          %{key: :hab_open_rich, level: 1, type: :building},
          %{key: :market_open, level: 1, type: :building}
        ]
      },
      %Data.Game.Patent{
        ancestor: :open_credit,
        class: :open,
        cost: 1250,
        illustration: "open_island.jpg",
        info: nil,
        key: :open_island,
        type: :building,
        unlock: [%{key: :ideo_credit_open, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :open_island,
        class: :open,
        cost: 2100,
        illustration: "open_lift.jpg",
        info: nil,
        key: :open_lift,
        type: :building,
        unlock: [%{key: :lift_open, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :open_lift,
        class: :open,
        cost: 2900,
        illustration: "open_happiness.jpg",
        info: nil,
        key: :open_happiness,
        type: :building,
        unlock: [%{key: :happy_pot_open, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :open_happiness,
        class: :open,
        cost: 4000,
        illustration: "open_mobility.jpg",
        info: nil,
        key: :open_mobility,
        type: :building,
        unlock: [%{key: :finance_open, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :citadel,
        class: :dome,
        cost: 50,
        illustration: "infra_dome_1.jpg",
        info: nil,
        key: :infra_dome_1,
        type: :building,
        unlock: [
          %{key: :infra_dome, level: 1, type: :building},
          %{key: :mine_dome, level: 1, type: :building},
          %{key: :research_dome, level: 1, type: :building}
        ]
      },
      %Data.Game.Patent{
        ancestor: :infra_dome_1,
        class: :dome,
        cost: 125,
        illustration: "dome_pop.jpg",
        info: nil,
        key: :dome_pop,
        type: :building,
        unlock: [
          %{key: :hab_dome, level: 1, type: :building},
          %{key: :market_dome, level: 1, type: :building}
        ]
      },
      %Data.Game.Patent{
        ancestor: :dome_pop,
        class: :dome,
        cost: 750,
        illustration: "dome_happiness.jpg",
        info: nil,
        key: :dome_happiness,
        type: :building,
        unlock: [
          %{key: :ideo_dome, level: 1, type: :building},
          %{key: :happy_pot_dome, level: 1, type: :building}
        ]
      },
      %Data.Game.Patent{
        ancestor: :dome_happiness,
        class: :dome,
        cost: 5000,
        illustration: "dome_ideo.jpg",
        info: nil,
        key: :dome_ideo,
        type: :building,
        unlock: [%{key: :monument_dome, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :infra_dome_1,
        class: :dome,
        cost: 50,
        illustration: "infra_dome_1.jpg",
        info: :infra_dome_2,
        key: :infra_dome_2,
        type: :building,
        unlock: [%{key: :infra_dome, level: 2, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :infra_dome_2,
        class: :dome,
        cost: 750,
        illustration: "dome_defense_1.jpg",
        info: nil,
        key: :dome_defense_1,
        type: :building,
        unlock: [%{key: :defense_local_dome, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :dome_defense_1,
        class: :dome,
        cost: 250,
        illustration: "infra_dome_1.jpg",
        info: :infra_dome_3,
        key: :infra_dome_3,
        type: :building,
        unlock: [%{key: :infra_dome, level: 3, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :infra_dome_3,
        class: :dome,
        cost: 2100,
        illustration: "dome_defense_2.jpg",
        info: nil,
        key: :dome_defense_2,
        type: :building,
        unlock: [%{key: :defense_global_dome, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :dome_defense_2,
        class: :dome,
        cost: 950,
        illustration: "infra_dome_1.jpg",
        info: :infra_dome_4,
        key: :infra_dome_4,
        type: :building,
        unlock: [%{key: :infra_dome, level: 4, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :infra_dome_4,
        class: :dome,
        cost: 2500,
        illustration: "infra_dome_1.jpg",
        info: :infra_dome_5,
        key: :infra_dome_5,
        type: :building,
        unlock: [%{key: :infra_dome, level: 5, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :infra_dome_1,
        class: :dome,
        cost: 350,
        illustration: "dome_mobility.jpg",
        info: nil,
        key: :dome_mobility,
        type: :building,
        unlock: [
          %{key: :lift_dome, level: 1, type: :building},
          %{key: :spatioport_dome, level: 1, type: :building}
        ]
      },
      %Data.Game.Patent{
        ancestor: :dome_mobility,
        class: :dome,
        cost: 1050,
        illustration: "dome_academy.jpg",
        info: nil,
        key: :dome_academy,
        type: :building,
        unlock: [
          %{key: :military_school_dome, level: 1, type: :building},
          %{key: :removecontact_dome, level: 1, type: :building}
        ]
      },
      %Data.Game.Patent{
        ancestor: :dome_academy,
        class: :dome,
        cost: 6000,
        illustration: "dome_industries.jpg",
        info: nil,
        key: :dome_industries,
        type: :building,
        unlock: [%{key: :high_factory_dome, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :citadel,
        class: :orbital,
        cost: 50,
        illustration: "orbital_credit.jpg",
        info: nil,
        key: :orbital_credit,
        type: :building,
        unlock: [%{key: :factory_orbital, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :orbital_credit,
        class: :orbital,
        cost: 100,
        illustration: "orbital_defense.jpg",
        info: nil,
        key: :orbital_defense,
        type: :building,
        unlock: [
          %{key: :defense_local_orbital, level: 1, type: :building},
          %{key: :happy_orbital, level: 1, type: :building}
        ]
      },
      %Data.Game.Patent{
        ancestor: :orbital_defense,
        class: :orbital,
        cost: 500,
        illustration: "orbital_prod.jpg",
        info: nil,
        key: :orbital_prod,
        type: :building,
        unlock: [%{key: :mine_orbital, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :orbital_prod,
        class: :orbital,
        cost: 1250,
        illustration: "orbital_radar.jpg",
        info: nil,
        key: :orbital_radar,
        type: :building,
        unlock: [%{key: :radar_orbital, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :orbital_credit,
        class: :orbital,
        cost: 150,
        illustration: "infra_orbital.jpg",
        info: :infra_orbital_2,
        key: :infra_orbital_2,
        type: :building,
        unlock: []
      },
      %Data.Game.Patent{
        ancestor: :infra_orbital_2,
        class: :orbital,
        cost: 500,
        illustration: "infra_orbital.jpg",
        info: :infra_orbital_3,
        key: :infra_orbital_3,
        type: :building,
        unlock: []
      },
      %Data.Game.Patent{
        ancestor: :infra_orbital_3,
        class: :orbital,
        cost: 1200,
        illustration: "infra_orbital.jpg",
        info: :infra_orbital_4,
        key: :infra_orbital_4,
        type: :building,
        unlock: []
      },
      %Data.Game.Patent{
        ancestor: :infra_orbital_4,
        class: :orbital,
        cost: 2750,
        illustration: "infra_orbital.jpg",
        info: :infra_orbital_5,
        key: :infra_orbital_5,
        type: :building,
        unlock: []
      },
      %Data.Game.Patent{
        ancestor: :orbital_credit,
        class: :orbital,
        cost: 200,
        illustration: "orbital_research.jpg",
        info: nil,
        key: :orbital_research,
        type: :building,
        unlock: [%{key: :research_orbital, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :orbital_research,
        class: :orbital,
        cost: 750,
        illustration: "orbital_happiness.jpg",
        info: nil,
        key: :orbital_happiness,
        type: :building,
        unlock: [%{key: :happy_pot_orbital, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :orbital_happiness,
        class: :orbital,
        cost: 3000,
        illustration: "orbital_mobility.jpg",
        info: nil,
        key: :orbital_mobility,
        type: :building,
        unlock: [
          %{key: :finance_orbital, level: 1, type: :building},
          %{key: :spatioport_orbital, level: 1, type: :building}
        ]
      },
      %Data.Game.Patent{
        ancestor: :citadel,
        class: :ship,
        cost: 175,
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
        class: :ship,
        cost: 300,
        illustration: "fighter_1.jpg",
        info: nil,
        key: :fighter_2,
        type: :ship,
        unlock: [%{key: :fighter_2, type: :ship}]
      },
      %Data.Game.Patent{
        ancestor: :fighter_2,
        class: :ship,
        cost: 650,
        illustration: "fighter_3.jpg",
        info: nil,
        key: :fighter_4,
        type: :ship,
        unlock: [%{key: :fighter_4, type: :ship}]
      },
      %Data.Game.Patent{
        ancestor: :shipyard_1,
        class: :ship,
        cost: 150,
        illustration: "fighter_4.jpg",
        info: nil,
        key: :fighter_3,
        type: :ship,
        unlock: [%{key: :fighter_3, type: :ship}]
      },
      %Data.Game.Patent{
        ancestor: :shipyard_1,
        class: :ship,
        cost: 400,
        illustration: "merge_fighter_1.jpg",
        info: :merge_fighter_1,
        key: :merge_fighter_1,
        type: :ship,
        unlock: []
      },
      %Data.Game.Patent{
        ancestor: :merge_fighter_1,
        class: :ship,
        cost: 450,
        illustration: "shipyard_2.jpg",
        info: nil,
        key: :shipyard_2,
        type: :building,
        unlock: [%{key: :shipyard_2_orbital, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :shipyard_2,
        class: :ship,
        cost: 1250,
        illustration: "merge_fighter_2.jpg",
        info: :merge_fighter_2,
        key: :merge_fighter_2,
        type: :ship,
        unlock: []
      },
      %Data.Game.Patent{
        ancestor: :merge_fighter_2,
        class: :ship,
        cost: 1500,
        illustration: "merge_corvette_1.jpg",
        info: :merge_corvette_1,
        key: :merge_corvette_1,
        type: :ship,
        unlock: []
      },
      %Data.Game.Patent{
        ancestor: :merge_corvette_1,
        class: :ship,
        cost: 1750,
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
        class: :ship,
        cost: 2500,
        illustration: "frigate_4.jpg",
        info: nil,
        key: :frigate_4,
        type: :ship,
        unlock: [%{key: :frigate_4, type: :ship}]
      },
      %Data.Game.Patent{
        ancestor: :frigate_4,
        class: :ship,
        cost: 1400,
        illustration: "frigate_3.jpg",
        info: nil,
        key: :frigate_3,
        type: :ship,
        unlock: [%{key: :frigate_3, type: :ship}]
      },
      %Data.Game.Patent{
        ancestor: :shipyard_3,
        class: :ship,
        cost: 2250,
        illustration: "transport_2.jpg",
        info: nil,
        key: :transport_2,
        type: :ship,
        unlock: [%{key: :transport_2, type: :ship}]
      },
      %Data.Game.Patent{
        ancestor: :transport_2,
        class: :ship,
        cost: 1900,
        illustration: "frigate_2.jpg",
        info: nil,
        key: :frigate_2,
        type: :ship,
        unlock: [%{key: :frigate_2, type: :ship}]
      },
      %Data.Game.Patent{
        ancestor: :shipyard_3,
        class: :ship,
        cost: 3000,
        illustration: "merge_fighter_3.jpg",
        info: :merge_fighter_3,
        key: :merge_fighter_3,
        type: :ship,
        unlock: []
      },
      %Data.Game.Patent{
        ancestor: :merge_fighter_3,
        class: :ship,
        cost: 3750,
        illustration: "merge_corvette_2.jpg",
        info: :merge_corvette_2,
        key: :merge_corvette_2,
        type: :ship,
        unlock: []
      },
      %Data.Game.Patent{
        ancestor: :merge_corvette_2,
        class: :ship,
        cost: 3750,
        illustration: "shipyard_4.jpg",
        info: nil,
        key: :shipyard_4,
        type: :building,
        unlock: [%{key: :shipyard_4_orbital, level: 1, type: :building}]
      },
      %Data.Game.Patent{
        ancestor: :shipyard_4,
        class: :ship,
        cost: 6250,
        illustration: "capital_1.jpg",
        info: nil,
        key: :capital_1,
        type: :ship,
        unlock: [%{key: :capital_1, type: :ship}]
      },
      %Data.Game.Patent{
        ancestor: :capital_1,
        class: :ship,
        cost: 7500,
        illustration: "capital_2.jpg",
        info: nil,
        key: :capital_2,
        type: :ship,
        unlock: [%{key: :capital_2, type: :ship}]
      },
      %Data.Game.Patent{
        ancestor: :shipyard_4,
        class: :ship,
        cost: 3750,
        illustration: "merge_frigate_1.jpg",
        info: :merge_frigate_1,
        key: :merge_frigate_1,
        type: :ship,
        unlock: []
      },
      %Data.Game.Patent{
        ancestor: :shipyard_4,
        class: :ship,
        cost: 5000,
        illustration: "capital_3.jpg",
        info: nil,
        key: :capital_3,
        type: :ship,
        unlock: [%{key: :capital_3, type: :ship}]
      },
      %Data.Game.Patent{
        ancestor: :shipyard_2,
        class: :ship,
        cost: 1100,
        illustration: "corvette_1.jpg",
        info: nil,
        key: :corvette_1,
        type: :ship,
        unlock: [%{key: :corvette_1, type: :ship}]
      },
      %Data.Game.Patent{
        ancestor: :shipyard_2,
        class: :ship,
        cost: 1400,
        illustration: "corvette_2.jpg",
        info: nil,
        key: :corvette_2,
        type: :ship,
        unlock: [%{key: :corvette_2, type: :ship}]
      },
      %Data.Game.Patent{
        ancestor: :corvette_2,
        class: :ship,
        cost: 2800,
        illustration: "corvette_3.jpg",
        info: nil,
        key: :corvette_3,
        type: :ship,
        unlock: [%{key: :corvette_3, type: :ship}]
      },
      %Data.Game.Patent{
        ancestor: :citadel,
        class: :ship,
        cost: 50,
        illustration: "transport_1.jpg",
        info: nil,
        key: :transport_1,
        type: :ship,
        unlock: [%{key: :transport_1, type: :ship}]
      }
    ]
  end
end
