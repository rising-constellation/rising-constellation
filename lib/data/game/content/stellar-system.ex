defmodule Data.Game.StellarSystem.Content do
  def data do
    [
      %Data.Game.StellarSystem{
        key: :white_dwarf,
        gen_body_number: 4..6,
        gen_prob_factor: 10,
        display_size_factor: 1.0
      },
      %Data.Game.StellarSystem{
        key: :red_dwarf,
        gen_body_number: 4..6,
        gen_prob_factor: 120,
        display_size_factor: 1.1
      },
      %Data.Game.StellarSystem{
        key: :orange_dwarf,
        gen_body_number: 5..7,
        gen_prob_factor: 110,
        display_size_factor: 1.3
      },
      %Data.Game.StellarSystem{
        key: :yellow_dwarf,
        gen_body_number: 6..8,
        gen_prob_factor: 100,
        display_size_factor: 1.5
      },
      %Data.Game.StellarSystem{
        key: :red_giant,
        gen_body_number: 5..7,
        gen_prob_factor: 5,
        display_size_factor: 2.0
      },
      %Data.Game.StellarSystem{
        key: :blue_giant,
        gen_body_number: 5..7,
        gen_prob_factor: 5,
        display_size_factor: 2.2
      }
    ]
  end
end
