defmodule Data.Game.Calendar.Content do
  def data do
    [
      %Data.Game.Calendar{
        key: :tetrarch,
        ut_to_day_factor: 1.0,
        days_in_month: 20,
        months_in_year: 24
      }
    ]
  end
end
