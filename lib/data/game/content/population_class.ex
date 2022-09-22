defmodule Data.Game.PopulationClass.Content do
  def data do
    [
      %Data.Game.PopulationClass{
        key: :prodigious,
        threshold: 160,
        points: 75
      },
      %Data.Game.PopulationClass{
        key: :enormous,
        threshold: 120,
        points: 25
      },
      %Data.Game.PopulationClass{
        key: :huge,
        threshold: 90,
        points: 16
      },
      %Data.Game.PopulationClass{
        key: :big,
        threshold: 80,
        points: 11
      },
      %Data.Game.PopulationClass{
        key: :major,
        threshold: 70,
        points: 7
      },
      %Data.Game.PopulationClass{
        key: :large,
        threshold: 60,
        points: 4
      },
      %Data.Game.PopulationClass{
        key: :medium,
        threshold: 40,
        points: 2
      },
      %Data.Game.PopulationClass{
        key: :minor,
        threshold: 0,
        points: 1
      }
    ]
  end
end
