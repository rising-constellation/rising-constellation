defmodule Data.Game.Calendar do
  use TypedStruct
  use Util.MakeEnumerable

  def jason(), do: []

  typedstruct enforce: true do
    field(:key, atom())
    field(:ut_to_day_factor, float())
    field(:days_in_month, integer())
    field(:months_in_year, integer())
  end

  def specs do
    "Elixir." <> module = Atom.to_string(__MODULE__)
    module = "#{module}.Content"

    [
      %{metadata: [], content_name: "calendar", module: module, sources: nil}
    ]
  end
end
