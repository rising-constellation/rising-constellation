defmodule Data.Game.Doctrine do
  use TypedStruct
  use Util.MakeEnumerable

  def jason(), do: []

  typedstruct enforce: true do
    field(:key, atom())
    field(:type, atom())
    field(:class, atom())
    field(:ancestor, [atom()])
    field(:illustration, String.t())
    field(:cost, integer())
    field(:bonus, [%Core.Bonus{}] | [])
  end

  def specs do
    "Elixir." <> module = Atom.to_string(__MODULE__)
    module = "#{module}.Content"

    [
      %{
        metadata: [speed: :fast],
        content_name: "doctrine-fast",
        module: module <> ".Fast",
        sources: {"1QFhTWcat_IBQ49cpayBZLja1SsWWxxBNGYsf7tNrhWE", "doctrine"}
      },
      %{
        metadata: [speed: :medium],
        content_name: "doctrine-medium",
        module: module <> ".Medium",
        sources: {"1npyGc-dqkiUWOvXOxcbURJ6YxQNcD71uJetmEbvYRzI", "doctrine"}
      },
      %{
        metadata: [speed: :slow],
        content_name: "doctrine-slow",
        module: module <> ".Slow",
        sources: {"1vIR5EilO5e8pqOTJx6rsJbjr2tiib2FrGtmLG1hvGK0", "doctrine"}
      }
    ]
  end

  def csv_to_struct(_header, data, _metadata) do
    bonus_codepoints = 6..11

    Enum.map(data, fn line ->
      [key, ancestor, type, class, illustration, cost | _rest] = line

      bonus =
        bonus_codepoints
        |> Enum.map(fn codepoint -> Enum.at(line, codepoint) end)
        |> Enum.filter(fn bonus -> bonus != "" end)
        |> Enum.map(&Data.Util.parse_bonus/1)

      %Data.Game.Doctrine{
        key: Data.Util.parse_atom(key),
        type: Data.Util.parse_atom(type),
        class: Data.Util.parse_atom(class),
        ancestor: Data.Util.parse_atom(ancestor),
        illustration: illustration,
        cost: Data.Util.parse_int(cost),
        bonus: bonus
      }
    end)
  end
end
