defmodule Instance.Character.Ship do
  use TypedStruct

  alias Instance.Character

  def jason(), do: []

  typedstruct enforce: true do
    field(:key, atom())
    field(:name, nil | String.t())
    field(:level, integer() | :hidden, default: 0)
    field(:experience, float() | :hidden, default: 0.0)
    field(:units, [%Character.ShipUnit{}] | :hidden)
  end

  def new(data, name \\ nil) do
    units = Enum.map(1..data.unit_count, fn i -> Character.ShipUnit.new(i, data) end)

    %Character.Ship{
      key: data.key,
      name: name,
      units: units
    }
  end

  def convert_from_battle(%Character.Ship{} = pre_fight_ship, %Fight.Ship{} = post_fight_ship) do
    units = Enum.map(post_fight_ship.units, fn unit -> Character.ShipUnit.convert(unit) end)
    gained_xp = Enum.min([post_fight_ship.gained_xp, 100]) / 5 + 5

    add_experience(%{pre_fight_ship | units: units}, gained_xp)
  end

  def total_hull(%Character.Ship{} = state) do
    Enum.reduce(state.units, 0, fn unit, acc -> acc + unit.hull end)
  end

  def is_destroyed(%Character.Ship{} = state) do
    # 0.001 is the value used to say "this unit is destroyed"
    # if all units in a ship have this value, the ship is destroyed
    Enum.all?(state.units, fn unit -> unit.hull == 0.001 end)
  end

  def add_experience(%Character.Ship{} = state, amount) do
    next_level_experience = get_next_level_experience(state)

    if amount > next_level_experience do
      state = %{state | experience: state.experience + next_level_experience, level: state.level + 1}
      add_experience(state, amount - next_level_experience)
    else
      %{state | experience: state.experience + amount}
    end
  end

  def damage(%Character.Ship{} = state, damage) do
    units = Enum.map(state.units, fn unit -> Character.ShipUnit.damage(unit, damage) end)
    %{state | units: units}
  end

  def repair(%Character.Ship{} = state, new_hull, missing_hull, data) do
    units =
      Enum.map(state.units, fn unit ->
        if missing_hull > 0 do
          unit_repair_hull = new_hull * (data.unit_hull - unit.hull) / missing_hull
          Character.ShipUnit.repair(unit, unit_repair_hull, data)
        else
          unit
        end
      end)

    %{state | units: units}
  end

  defp get_next_level_experience(%Character.Ship{} = state) do
    Float.round(10 * (state.level + 1) + :math.pow((state.level + 1) / 2, 2.5)) - state.experience
  end

  def obfuscate(%Character.Ship{} = state, visibility_level) do
    case visibility_level do
      4 -> %{state | level: :hidden, experience: :hidden, units: :hidden}
      5 -> state
    end
  end
end
