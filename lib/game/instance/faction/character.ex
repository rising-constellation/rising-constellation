defmodule Instance.Faction.Character do
  use TypedStruct
  use Util.MakeEnumerable

  alias Instance.Faction
  alias Instance.Character
  alias Instance.Character.Tile

  def jason(), do: []

  typedstruct enforce: false do
    field(:id, integer())
    field(:status, atom())
    field(:type, atom())
    field(:specialization, atom())
    field(:skills, [integer()])
    field(:age, integer())
    field(:culture, atom())
    field(:name, String.t())
    field(:gender, atom())
    field(:illustration, String.t())
    field(:level, integer())
    field(:experience, %Core.DynamicValue{})
    field(:protection, integer())
    field(:determination, integer())
    field(:owner, %Character.Player{} | nil)
    field(:system, integer() | nil)
    field(:action_status, atom())
    field(:on_strike, boolean())
    field(:army, %Character.Army{} | nil)
    field(:spy, %Character.Spy{} | nil)
    field(:speaker, %Character.Speaker{} | nil)
  end

  def obfuscate(%Character.Character{} = character, visibility_level) do
    new_character = %Faction.Character{}

    fields_levels = %{
      2 => [:id, :status, :type, :name, :illustration, :level, :owner, :system],
      3 => [:gender],
      4 => [:specialization, :age, :culture],
      5 => [:skills, :experience, :protection, :determination, :action_status, :on_strike]
    }

    # filter fields
    new_character =
      Enum.reduce(fields_levels, new_character, fn {level, fields}, new_character ->
        if level <= visibility_level do
          Enum.reduce(fields, new_character, fn field, new_character ->
            Map.put(new_character, field, Map.get(character, field))
          end)
        else
          new_character
        end
      end)

    # filter army if admiral
    new_character =
      if character.type == :admiral and character.status == :on_board,
        do: %{new_character | army: obfuscate_army(character.army, visibility_level)},
        else: new_character

    # filter spy if spy
    new_character =
      if character.type == :spy and character.status == :on_board,
        do: %{new_character | spy: obfuscate_spy(character.spy, visibility_level)},
        else: new_character

    # filter speaker if speaker
    if character.type == :speaker and character.status == :on_board,
      do: %{new_character | speaker: obfuscate_speaker(character.speaker, visibility_level)},
      else: new_character
  end

  def obfuscate_army(%Character.Army{} = army, visibility_level) do
    fields_levels = %{
      4 => [:maintenance],
      5 => [:reaction, :repair_coef, :invasion_coef, :raid_coef]
    }

    # filter fields
    new_army =
      Enum.reduce(fields_levels, %{}, fn {level, fields}, new_army ->
        if level <= visibility_level do
          Enum.reduce(fields, new_army, fn field, new_army ->
            Map.put(new_army, field, Map.get(army, field))
          end)
        else
          new_army
        end
      end)

    tiles = Enum.map(army.tiles, fn tile -> Tile.obfuscate(tile, visibility_level) end)
    Map.put(new_army, :tiles, tiles)
  end

  def obfuscate_spy(%Character.Spy{} = spy, visibility_level) do
    # cover will never be shown
    fields_levels = %{
      5 => [:infiltrate_coef, :sabotage_coef, :assassination_coef],
      6 => [:cover]
    }

    # filter fields
    Enum.reduce(fields_levels, %{}, fn {level, fields}, new_spy ->
      if level <= visibility_level do
        Enum.reduce(fields, new_spy, fn field, new_spy ->
          Map.put(new_spy, field, Map.get(spy, field))
        end)
      else
        new_spy
      end
    end)
  end

  def obfuscate_speaker(%Character.Speaker{} = speaker, visibility_level) do
    # cooldown will never be shown
    fields_levels = %{
      5 => [:make_dominion_coef, :encourage_hate_coef, :conversion_coef],
      6 => [:cooldown]
    }

    # filter fields
    Enum.reduce(fields_levels, %{}, fn {level, fields}, new_speaker ->
      if level <= visibility_level do
        Enum.reduce(fields, new_speaker, fn field, new_speaker ->
          Map.put(new_speaker, field, Map.get(speaker, field))
        end)
      else
        new_speaker
      end
    end)
  end
end
