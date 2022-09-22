defmodule Data.Game.BonusPipelineOut do
  use TypedStruct
  use Util.MakeEnumerable

  def jason(), do: []

  typedstruct enforce: true do
    field(:key, atom())
    field(:to, atom())
    field(:to_key, atom() | nil)
    field(:icon, String.t() | nil)
  end

  def specs do
    "Elixir." <> module = Atom.to_string(__MODULE__)
    module = "#{module}.Content"

    [
      %{metadata: [], content_name: "bonus-pipeline-out", module: module, sources: nil}
    ]
  end
end
