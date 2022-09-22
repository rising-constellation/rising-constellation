defmodule Data.Game.PopulationStatus do
  use TypedStruct
  use Util.MakeEnumerable

  def jason(), do: []

  typedstruct enforce: true do
    field(:key, atom())
    field(:threshold, integer())
    field(:display_max, integer())
    field(:display_min, integer())
    field(:penalty, float())
  end

  def specs do
    "Elixir." <> module = Atom.to_string(__MODULE__)
    module = "#{module}.Content"

    [
      %{metadata: [], content_name: "uprising", module: module, sources: nil}
    ]
  end
end
