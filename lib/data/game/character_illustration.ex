defmodule Data.Game.CharacterIllustration do
  use TypedStruct
  use Util.MakeEnumerable

  def jason(), do: []

  typedstruct enforce: true do
    field(:key, integer())
    field(:filename, String.t())
    field(:type, atom())
    field(:age, Range.t())
    field(:gender, atom())
    field(:rank, integer())
    field(:only_specialization, atom() | nil)
    field(:pref_specializations, [atom()] | [])
    field(:forb_specializations, [atom()] | [])
    field(:culture, atom())
  end

  def specs do
    "Elixir." <> module = Atom.to_string(__MODULE__)
    module = "#{module}.Content"

    [
      %{
        metadata: [],
        content_name: "character-illustration",
        module: module,
        sources: {"1WIXwVLtFRWl_ZW2zP9RqoUZkhqSWS0KncRlUkbcYAiQ", "data"}
      }
    ]
  end

  def csv_to_struct(_header, data, _metadata) do
    Enum.map(Enum.with_index(data, 1), fn {line, index} ->
      [filename, type, age, gender, rank, only, pref, _forb, culture | _rest] = line

      character_type =
        type
        |> String.slice(1..-1)
        |> String.to_atom()

      data = Data.Querier.fetch_one(Data.Game.Character, [], character_type)
      rank = Data.Querier.fetch_one(Data.Game.CharacterRank, [], :id, String.to_integer(rank))

      only =
        if String.length(only) == 0,
          do: nil,
          else: Enum.at(data.specializations, String.to_integer(only) - 1)

      # TODO: read forb_specializations from data
      # for now we juste put empty list (because there are not enough character_illustration)
      # forb_specializations: int_to_specialization(data, forb)

      %Data.Game.CharacterIllustration{
        key: index,
        filename: filename,
        type: Data.Util.parse_atom(type),
        age: Data.Util.parse_range(age),
        gender: Data.Util.parse_atom(gender),
        rank: rank.key,
        only_specialization: only,
        pref_specializations: int_to_specialization(data, pref),
        forb_specializations: [],
        culture: Data.Util.parse_atom(culture)
      }
    end)
  end

  defp int_to_specialization(data, string) do
    case string do
      "" ->
        []

      _ ->
        String.split(string, ",")
        |> Enum.map(fn s ->
          Enum.at(data.specializations, String.to_integer(s) - 1).key
        end)
    end
  end
end
