defmodule Data.Game.Culture.Content do
  def data do
    [
      %Data.Game.Culture{
        key: :tetrarchic,
        firstname_repo: %{
          male: "male-firstname",
          female: "female-firstname"
        },
        lastname_repo: "tetrarchic-foundation"
      },
      %Data.Game.Culture{
        key: :myrmeziriannic,
        firstname_repo: %{
          male: "male-firstname",
          female: "female-firstname"
        },
        lastname_repo: "myrmeziriannic-foundation"
      },
      %Data.Game.Culture{
        key: :cardanic,
        firstname_repo: %{
          male: "male-firstname",
          female: "female-firstname"
        },
        lastname_repo: "cardanic-foundation"
      },
      %Data.Game.Culture{
        key: :syn,
        firstname_repo: %{
          male: "male-firstname",
          female: "female-firstname"
        },
        lastname_repo: "syn-foundation"
      },
      %Data.Game.Culture{
        key: :stelloliberalism,
        firstname_repo: %{
          male: "male-firstname",
          female: "female-firstname"
        },
        lastname_repo: "stelloliberalism-foundation"
      }
    ]
  end
end
