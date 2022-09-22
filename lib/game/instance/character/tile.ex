defmodule Instance.Character.Tile do
  use TypedStruct
  use Util.MakeEnumerable

  alias Instance.Character

  def jason(), do: []

  typedstruct enforce: true do
    field(:id, integer())
    field(:ship_status, :empty | :planned | :filled)
    field(:ship, %Character.Ship{} | :hidden | nil)
  end

  def new(id) do
    %Character.Tile{
      id: id,
      ship_status: :empty,
      ship: nil
    }
  end

  def convert_from_battle(%Character.Tile{} = pre_fight_tile, %Fight.Tile{} = post_fight_tile) do
    ship =
      case post_fight_tile.ship_status do
        :filled -> Character.Ship.convert_from_battle(pre_fight_tile.ship, post_fight_tile.ship)
        :planned -> pre_fight_tile.ship
        _ -> nil
      end

    %Character.Tile{
      id: post_fight_tile.id,
      ship_status: post_fight_tile.ship_status,
      ship: ship
    }
  end

  def plan_ship(%Character.Tile{} = state, ship_data, name) do
    %{state | ship_status: :planned, ship: Character.Ship.new(ship_data, name)}
  end

  def unplan_ship(%Character.Tile{} = state) do
    %{state | ship_status: :empty, ship: nil}
  end

  def put_ship(%Character.Tile{} = state, initial_xp, _constant) do
    %{state | ship_status: :filled, ship: Character.Ship.add_experience(state.ship, initial_xp)}
  end

  def remove_ship(%Character.Tile{} = state) do
    %{state | ship_status: :empty, ship: nil}
  end

  def total_hull(%Character.Tile{ship_status: :filled} = state), do: Character.Ship.total_hull(state.ship)
  def total_hull(%Character.Tile{} = _state), do: 0.0

  def obfuscate(%Character.Tile{ship_status: :filled} = state, visibility_level) do
    case visibility_level do
      0 -> %{state | ship: :hidden}
      1 -> %{state | ship: :hidden}
      2 -> %{state | ship: :hidden}
      3 -> %{state | ship: :hidden}
      4 -> %{state | ship: Character.Ship.obfuscate(state.ship, visibility_level)}
      5 -> %{state | ship: Character.Ship.obfuscate(state.ship, visibility_level)}
    end
  end

  def obfuscate(%Character.Tile{} = state, visibility_level) do
    case visibility_level do
      0 -> %{state | ship_status: :empty}
      1 -> %{state | ship_status: :empty}
      2 -> %{state | ship_status: :empty}
      3 -> %{state | ship_status: :empty}
      4 -> %{state | ship_status: :empty}
      5 -> state
    end
  end
end
