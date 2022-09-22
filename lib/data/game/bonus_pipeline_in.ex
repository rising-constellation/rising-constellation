defmodule Data.Game.BonusPipelineIn do
  use TypedStruct
  use Util.MakeEnumerable

  def jason(), do: []

  typedstruct enforce: true do
    field(:key, atom())
    field(:from, atom())
    field(:from_key, atom() | nil)
    field(:icon, String.t() | nil)
    field(:order, integer())
  end

  def specs do
    "Elixir." <> module = Atom.to_string(__MODULE__)
    module = "#{module}.Content"

    [
      %{metadata: [], content_name: "bonus-pipeline-in", module: module, sources: nil}
    ]
  end
end
