defmodule Data.Game.Faction do
  use TypedStruct
  use Util.MakeEnumerable

  def jason(), do: [except: [:initial_character_spec2, :initial_character_skills]]

  typedstruct enforce: true do
    field(:key, atom())
    field(:culture, atom())
    field(:initial_character_type, atom())
    field(:initial_character_spec1, atom())
    field(:initial_character_spec2, atom())
    field(:initial_character_skills, [number()])
    field(:traditions, [%{}])
    field(:theme, String.t())
    field(:color, String.t())
  end

  def specs do
    "Elixir." <> module = Atom.to_string(__MODULE__)
    module = "#{module}.Content"

    [
      %{metadata: [], content_name: "faction", module: module, sources: nil}
    ]
  end
end
