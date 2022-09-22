defmodule Data.Game.Character do
  use TypedStruct
  use Util.MakeEnumerable

  def jason(), do: [except: [:credit_cost_range, :technology_cost_range, :ideology_cost_range]]

  typedstruct enforce: true do
    field(:key, atom())
    field(:initial_protection, integer())
    field(:initial_determination, integer())
    field(:gain_protection, integer())
    field(:max_protection, integer())
    field(:gain_determination, integer())
    field(:max_determination, integer())
    field(:specializations, [atom()])
    field(:credit_cost_range, Range.t())
    field(:technology_cost_range, Range.t())
    field(:ideology_cost_range, Range.t())
  end

  def specs do
    "Elixir." <> module = Atom.to_string(__MODULE__)
    module = "#{module}.Content"

    [
      %{metadata: [speed: :medium], content_name: "character-medium", module: module <> ".Medium", sources: nil},
      %{metadata: [], content_name: "character", module: module, sources: nil}
    ]
  end
end
