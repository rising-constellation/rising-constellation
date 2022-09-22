defmodule Instance.StellarSystem.StarterStellarSystemData do
  def content() do
    [
      %{
        "act_factor" => 1,
        "ind_factor" => 4,
        "key" => "sterile_planet",
        "subbodies" => [],
        "tec_factor" => 3,
        "tiles" => 6,
        "type" => "primary"
      },
      %{
        "act_factor" => 5,
        "ind_factor" => 4,
        "key" => "habitable_planet",
        "subbodies" => [
          %{
            "act_factor" => 1,
            "ind_factor" => 2,
            "key" => "moon",
            "subbodies" => [],
            "tec_factor" => 1,
            "tiles" => 2,
            "type" => "secondary"
          }
        ],
        "tec_factor" => 2,
        "tiles" => 5,
        "type" => "primary"
      },
      %{
        "act_factor" => 0,
        "ind_factor" => 0,
        "key" => "asteroid_belt",
        "subbodies" => [
          %{
            "act_factor" => 4,
            "ind_factor" => 2,
            "key" => "asteroid",
            "subbodies" => [],
            "tec_factor" => 3,
            "tiles" => 3,
            "type" => "secondary"
          },
          %{
            "act_factor" => 1,
            "ind_factor" => 5,
            "key" => "asteroid",
            "subbodies" => [],
            "tec_factor" => 4,
            "tiles" => 2,
            "type" => "secondary"
          },
          %{
            "act_factor" => 4,
            "ind_factor" => 2,
            "key" => "asteroid",
            "subbodies" => [],
            "tec_factor" => 4,
            "tiles" => 3,
            "type" => "secondary"
          }
        ],
        "tec_factor" => 0,
        "tiles" => 0,
        "type" => "primary"
      },
      %{
        "act_factor" => 4,
        "ind_factor" => 1,
        "key" => "habitable_planet",
        "subbodies" => [],
        "tec_factor" => 3,
        "tiles" => 8,
        "type" => "primary"
      },
      %{
        "act_factor" => 0,
        "ind_factor" => 0,
        "key" => "gaseous_giant",
        "subbodies" => [
          %{
            "act_factor" => 1,
            "ind_factor" => 5,
            "key" => "moon",
            "subbodies" => [],
            "tec_factor" => 4,
            "tiles" => 2,
            "type" => "secondary"
          },
          %{
            "act_factor" => 4,
            "ind_factor" => 2,
            "key" => "moon",
            "subbodies" => [],
            "tec_factor" => 4,
            "tiles" => 3,
            "type" => "secondary"
          }
        ],
        "tec_factor" => 0,
        "tiles" => 0,
        "type" => "primary"
      }
    ]
  end
end
