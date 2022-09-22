defmodule Data.Game.StellarSystem do
  use TypedStruct
  use Util.MakeEnumerable

  def jason(), do: [except: [:gen_body_number]]

  typedstruct enforce: true do
    field(:key, atom())
    field(:gen_body_number, Range.t())
    field(:gen_prob_factor, integer())
    field(:display_size_factor, float())
  end

  def specs do
    "Elixir." <> module = Atom.to_string(__MODULE__)
    module = "#{module}.Content"

    [
      %{metadata: [], content_name: "stellar-system", module: module, sources: nil}
    ]
  end
end
