defmodule Data.Game.PopulationClass do
  use TypedStruct
  use Util.MakeEnumerable

  def jason(), do: []

  typedstruct enforce: true do
    field(:key, atom())
    field(:threshold, integer())
    field(:points, float())
  end

  def specs do
    "Elixir." <> module = Atom.to_string(__MODULE__)
    module = "#{module}.Content"

    [
      %{metadata: [], content_name: "population-class", module: module, sources: nil}
    ]
  end
end
