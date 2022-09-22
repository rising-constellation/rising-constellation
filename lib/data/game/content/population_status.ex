defmodule Data.Game.PopulationStatus.Content do
  def data do
    [
      %Data.Game.PopulationStatus{
        key: :normal,
        threshold: 10_000,
        display_max: 10,
        display_min: 0,
        penalty: 0
      },
      %Data.Game.PopulationStatus{
        key: :discontent,
        threshold: 0,
        display_max: 0,
        display_min: -10,
        penalty: 0.1
      },
      %Data.Game.PopulationStatus{
        key: :demonstration,
        threshold: -10,
        display_max: -10,
        display_min: -20,
        penalty: 0.25
      },
      %Data.Game.PopulationStatus{
        key: :uprising,
        threshold: -20,
        display_max: -20,
        display_min: -30,
        penalty: 0.5
      },
      %Data.Game.PopulationStatus{
        key: :general_uprising,
        threshold: -30,
        display_max: -30,
        display_min: -40,
        penalty: 0.8
      }
    ]
  end
end
