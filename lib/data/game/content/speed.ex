defmodule Data.Game.Speed.Content do
  def data do
    [
      %Data.Game.Speed{
        key: :fast,
        value: 1,
        factor: 120
      },
      %Data.Game.Speed{
        key: :medium,
        value: 2,
        factor: 20
      },
      %Data.Game.Speed{
        key: :slow,
        value: 3,
        factor: 1
      }
    ]
  end
end
