defmodule Data.Game.StellarBody do
  use TypedStruct
  use Util.MakeEnumerable

  def jason(),
    do: [
      except: [
        :gen_tiles_number,
        :gen_subbody_number,
        :gen_ind_factor_number,
        :gen_tec_factor_number,
        :gen_act_factor_number
      ]
    ]

  typedstruct enforce: true do
    field(:key, atom())
    field(:type, atom())
    field(:biome, atom())
    field(:gen_tiles_number, Range.t())
    field(:gen_subbody_number, Range.t())
    field(:gen_subbody_types, [atom()])
    field(:gen_ind_factor_number, Range.t())
    field(:gen_tec_factor_number, Range.t())
    field(:gen_act_factor_number, Range.t())
  end

  def specs do
    "Elixir." <> module = Atom.to_string(__MODULE__)
    module = "#{module}.Content"

    [
      %{metadata: [], content_name: "stellar-body", module: module, sources: nil}
    ]
  end
end
