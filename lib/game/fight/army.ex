defmodule Fight.Army do
  use TypedStruct

  @line_size 3
  @turn_delay 2

  # def jason(), do: []
  typedstruct enforce: true do
    field(:id, integer())
    field(:side, :left | :right)
    field(:level, integer())
    field(:experience, integer())
    field(:tiles, [%Fight.Tile{}])
    field(:tiles_shift, integer())
    field(:delay, integer())
  end

  def convert(character, side, constant, ships_data) do
    tiles =
      Enum.map(character.army.tiles, fn tile ->
        Fight.Tile.convert(tile, character.id, character.level, constant, ships_data)
      end)

    shift = Enum.find_index(tiles, fn t -> t.ship_status == :filled end)
    shift = if shift == nil, do: 0, else: shift
    shift = if shift > 0, do: trunc(shift / @line_size), else: 0

    %Fight.Army{
      id: character.id,
      side: side,
      level: character.level,
      experience: character.experience.value,
      tiles: tiles,
      tiles_shift: shift,
      delay: 0
    }
  end

  def get_ready_ships(state, turn) do
    turn_with_delay = turn - state.delay

    if turn_with_delay > 0 and rem(turn_with_delay - 1, @turn_delay) == 0 do
      ready_tiles = line_to_tile(trunc(turn_with_delay / @turn_delay) + state.tiles_shift)
      ready_tiles = ready_tiles..(ready_tiles + @line_size - 1)

      state.tiles
      |> Enum.filter(fn t -> Enum.member?(Enum.to_list(ready_tiles), t.id) and t.ship_status == :filled end)
      |> Enum.map(fn t -> t.ship end)
    else
      []
    end
  end

  def has_reinforcement?(state, turn) do
    next_line = trunc((turn - state.delay - 1) / @turn_delay) + state.tiles_shift + 1
    next_tile = line_to_tile(next_line)

    Enum.count(state.tiles, fn t -> t.id >= next_tile and t.ship_status != :empty end) > 0
  end

  def update_ship(state, {_, tile_id}, ship) do
    Enum.map(state.tiles, fn t ->
      if t.id == tile_id,
        do: Fight.Tile.update_ship(t, ship),
        else: t
    end)
  end

  defp line_to_tile(line) do
    line * @line_size + 1
  end
end
