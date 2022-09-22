defmodule Instance.Victory.Faction do
  use TypedStruct
  use Util.MakeEnumerable

  alias Instance.Victory

  def jason(), do: []

  typedstruct enforce: true do
    field(:id, integer())
    field(:key, atom())
    field(:player_count, integer())
    field(:possession_count, integer())
    field(:system_count, integer())
    field(:dominion_count, integer())
    field(:population_points, integer())
    field(:visibility_count, integer())
    field(:conquest_track, %{})
    field(:population_track, %{})
    field(:visibility_track, %{})
    field(:victory_points, integer())
  end

  def convert(faction) do
    %Victory.Faction{
      id: faction.id,
      key: faction.key,
      player_count: 0,
      possession_count: 0,
      system_count: 0,
      dominion_count: 0,
      population_points: 0,
      visibility_count: 0,
      conquest_track: %{},
      population_track: %{},
      visibility_track: %{},
      victory_points: 0
    }
  end

  def add_player(state) do
    %{state | player_count: state.player_count + 1}
  end

  def reset_player_count(state, players) do
    player_count =
      Enum.reduce(players, 0, fn {_id, p}, acc ->
        if p.faction == state.key and p.is_active,
          do: acc + 1,
          else: acc
      end)

    %{state | player_count: player_count}
  end

  def update_systems_count(state, {possession_count, system_count, dominion_count, population_points}) do
    %{
      state
      | possession_count: possession_count,
        system_count: system_count,
        dominion_count: dominion_count,
        population_points: population_points
    }
  end

  def update_visibility(state, visibility_count) do
    %{state | visibility_count: visibility_count}
  end
end
