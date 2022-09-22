defmodule Instance.StellarSystem.Character do
  use TypedStruct
  use Util.MakeEnumerable

  alias Instance.StellarSystem

  def jason(), do: []

  typedstruct enforce: false do
    field(:id, integer())
    field(:type, atom())
    field(:name, String.t())
    field(:level, integer())
    field(:owner, %Instance.Character.Player{})
    field(:protection, integer())
    field(:determination, integer())
    field(:cover, float() | nil)
  end

  def convert(character) do
    cover =
      if character.spy,
        do: character.spy.cover.value,
        else: nil

    %StellarSystem.Character{
      id: character.id,
      type: character.type,
      name: character.name,
      level: character.level,
      owner: character.owner,
      protection: character.protection,
      determination: character.determination,
      cover: cover
    }
  end

  def obfuscate(%StellarSystem.Character{} = character, visibility_level) do
    new_character = %StellarSystem.Character{}

    fields_levels = %{
      2 => [:id, :type, :name, :level, :owner],
      3 => [],
      4 => [:determination],
      5 => [:protection],
      6 => [:cover]
    }

    # filter fields
    Enum.reduce(fields_levels, new_character, fn {level, fields}, new_character ->
      if level <= visibility_level do
        Enum.reduce(fields, new_character, fn field, new_character ->
          Map.put(new_character, field, Map.get(character, field))
        end)
      else
        new_character
      end
    end)
  end
end
