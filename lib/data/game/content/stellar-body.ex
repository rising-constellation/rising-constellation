defmodule Data.Game.StellarBody.Content do
  def data do
    [
      %Data.Game.StellarBody{
        key: :habitable_planet,
        type: :primary,
        biome: :open,
        gen_tiles_number: 6..8,
        gen_subbody_number: 0..1,
        gen_subbody_types: [:moon],
        gen_ind_factor_number: 1..5,
        gen_tec_factor_number: 1..5,
        gen_act_factor_number: 1..5
      },
      %Data.Game.StellarBody{
        key: :sterile_planet,
        type: :primary,
        biome: :dome,
        gen_tiles_number: 6..8,
        gen_subbody_number: 0..1,
        gen_subbody_types: [:moon],
        gen_ind_factor_number: 1..5,
        gen_tec_factor_number: 1..5,
        gen_act_factor_number: 1..5
      },
      %Data.Game.StellarBody{
        key: :gaseous_giant,
        type: :primary,
        biome: :none,
        gen_tiles_number: 0..0,
        gen_subbody_number: 1..3,
        gen_subbody_types: [:moon],
        gen_ind_factor_number: 0..0,
        gen_tec_factor_number: 0..0,
        gen_act_factor_number: 0..0
      },
      %Data.Game.StellarBody{
        key: :asteroid_belt,
        type: :primary,
        biome: :none,
        gen_tiles_number: 0..0,
        gen_subbody_number: 1..4,
        gen_subbody_types: [:asteroid],
        gen_ind_factor_number: 0..0,
        gen_tec_factor_number: 0..0,
        gen_act_factor_number: 0..0
      },
      %Data.Game.StellarBody{
        key: :moon,
        type: :secondary,
        biome: :orbital,
        gen_tiles_number: 1..3,
        gen_subbody_number: 0..0,
        gen_subbody_types: [],
        gen_ind_factor_number: 1..5,
        gen_tec_factor_number: 1..5,
        gen_act_factor_number: 1..4
      },
      %Data.Game.StellarBody{
        key: :asteroid,
        type: :secondary,
        biome: :orbital,
        gen_tiles_number: 1..3,
        gen_subbody_number: 0..0,
        gen_subbody_types: [],
        gen_ind_factor_number: 1..5,
        gen_tec_factor_number: 1..4,
        gen_act_factor_number: 1..5
      }
    ]
  end
end
