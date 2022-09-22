defmodule Data.Game.CharacterRank do
  use TypedStruct
  use Util.MakeEnumerable

  def jason(),
    do: [
      except: [
        :initial_experience_range,
        :initial_protection_range,
        :initial_determination_range,
        :initial_skill_points_range
      ]
    ]

  typedstruct enforce: true do
    field(:key, atom())
    field(:id, integer())
    field(:size, integer())
    field(:initial_experience_range, Range.t())
    field(:initial_protection_range, Range.t())
    field(:initial_determination_range, Range.t())
    field(:initial_skill_points_range, Range.t())
    field(:cost_factor, integer())
    field(:nth_factor, float())
  end

  def specs do
    "Elixir." <> module = Atom.to_string(__MODULE__)
    module = "#{module}.Content"

    [
      %{metadata: [], content_name: "character-rank", module: module, sources: nil}
    ]
  end
end
