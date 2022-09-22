defmodule Instance.Victory.Victory do
  use TypedStruct

  alias Instance.Victory
  alias Portal.Controllers.FactionChannel

  @tick_interval 10
  @final_unit_days 200
  @next_update_unit_days 20

  def jason(), do: [except: [:instance_id, :next_update]]

  typedstruct enforce: true do
    field(:ut_time_left, float())
    field(:victory_points, integer())
    field(:inhabitable_systems_count, integer())
    field(:factions, [%Victory.Faction{}])
    field(:sectors, [%Victory.Sector{}])
    field(:winner, nil | atom())
    field(:instance_id, integer())
    field(:next_update, %Core.DynamicValue{})
  end

  def new(ut_time_left, victory_points, inhabitable_systems, sectors, factions, instance_id) do
    next_update = Core.DynamicValue.new(0, :misc, Core.ValuePart.new(:default, 1))

    %Victory.Victory{
      ut_time_left: ut_time_left,
      victory_points: victory_points,
      inhabitable_systems_count: inhabitable_systems,
      factions: Enum.map(factions, &Victory.Faction.convert/1),
      sectors: Enum.map(sectors, &Victory.Sector.convert/1),
      winner: nil,
      instance_id: instance_id,
      next_update: next_update
    }
  end

  def update_sector(state, new_sector) do
    sectors =
      Enum.map(state.sectors, fn sector ->
        if sector.id == new_sector.id,
          do: Victory.Sector.convert(new_sector),
          else: sector
      end)

    %{state | sectors: sectors} |> update_tracks()
  end

  def add_player(state, faction_id) do
    factions =
      Enum.map(state.factions, fn faction ->
        if faction.id == faction_id,
          do: Victory.Faction.add_player(faction),
          else: faction
      end)

    %{state | factions: factions} |> update_tracks()
  end

  def reset_player_count(state, players) do
    factions = Enum.map(state.factions, fn f -> Victory.Faction.reset_player_count(f, players) end)
    %{state | factions: factions}
  end

  def update_systems(state, systems) do
    factions =
      Enum.map(state.factions, fn faction ->
        counts =
          systems
          |> Enum.filter(fn s -> s.faction == faction.key end)
          |> Enum.reduce({0, 0, 0, 0}, fn s, {possession_count, system_count, dominion_count, population_points} ->
            possession_count = possession_count + 1
            system_count = if s.status == :inhabited_player, do: system_count + 1, else: system_count
            dominion_count = if s.status == :inhabited_dominion, do: dominion_count + 1, else: dominion_count

            class = Data.Querier.one(Data.Game.PopulationClass, state.instance_id, s.class)
            population_points = population_points + class.points

            {possession_count, system_count, dominion_count, population_points}
          end)

        Victory.Faction.update_systems_count(faction, counts)
      end)

    %{state | factions: factions} |> update_tracks()
  end

  def update_visibility(state, faction_key, visibility_count) do
    factions =
      Enum.map(state.factions, fn faction ->
        if faction.key == faction_key,
          do: Victory.Faction.update_visibility(faction, visibility_count),
          else: faction
      end)

    %{state | factions: factions} |> update_tracks()
  end

  def compute_next_tick_interval(_state),
    do: @tick_interval

  # Tick handling

  def next_tick(state, elapsed_time) do
    {MapSet.new(), state, nil}
    |> update_next_update(elapsed_time)
    |> decrease_ut_time_left(elapsed_time)
    |> check_for_victory(elapsed_time)
    |> check_for_closing_game(elapsed_time)
  end

  # Core functions

  defp update_next_update({change, state, export}, elapsed_time) do
    next_update = Core.DynamicValue.next_tick(state.next_update, elapsed_time)

    {next_update, change} =
      if next_update.value >= @next_update_unit_days do
        next_update = Core.DynamicValue.change_value(next_update, 0.0)
        change = MapSet.put(change, :victory_update)
        {next_update, change}
      else
        {next_update, change}
      end

    {change, %{state | next_update: next_update}, export}
  end

  defp decrease_ut_time_left({change, state, export}, elapsed_time) do
    {change, %{state | ut_time_left: state.ut_time_left - elapsed_time}, export}
  end

  defp check_for_victory({change, %{winner: nil} = state, export}, _elapsed_time) do
    # check if instance has reached the time limit
    time_is_up = state.ut_time_left <= 0

    # check victory
    current_rankings = Enum.sort(state.factions, fn a, b -> a.victory_points >= b.victory_points end)
    leader = List.first(current_rankings)
    has_winner = leader.victory_points >= 14

    victory_type =
      cond do
        time_is_up -> "win_on_time"
        has_winner -> "victory_track"
        true -> false
      end

    if victory_type do
      state = %{state | winner: leader.key, ut_time_left: @final_unit_days}
      change = change |> MapSet.put(:victory) |> MapSet.put(:victory_update)
      export = %{ranking: current_rankings, victory_type: victory_type}
      {change, state, export}
    else
      {change, state, export}
    end
  end

  defp check_for_victory({change, state, export}, _elapsed_time) do
    {change, state, export}
  end

  defp check_for_closing_game({change, state, export}, _elapsed_time) do
    if state.winner != nil and state.ut_time_left <= 0 and not any_connected_players?(state),
      do: {MapSet.put(change, :close_game), state, export},
      else: {change, state, export}
  end

  defp update_tracks(state) do
    total_sector_points = Enum.reduce(state.sectors, 0, fn s, acc -> acc + s.value end)
    total_player_count = Enum.reduce(state.factions, 0, fn f, acc -> acc + f.player_count end)
    total_faction_count = length(state.factions)

    factions =
      Enum.map(state.factions, fn faction ->
        faction_weighting =
          if total_player_count > 0 do
            weight = :math.pow(faction.player_count / (total_player_count / total_faction_count), 0.5)
            Enum.max([Enum.min([weight, 1.5]), 0.5])
          else
            1
          end

        foreign_possessions =
          state.factions
          |> Enum.filter(fn f -> f.key != faction.key end)
          |> Enum.reduce(0, fn f, acc -> acc + f.possession_count end)

        # conquest
        conquest_points =
          state.sectors
          |> Enum.filter(fn s -> s.owner == faction.key end)
          |> Enum.reduce(0, fn s, acc -> acc + s.value end)

        conquest_thresholds =
          [0.0, 0.25, 0.6, 0.95]
          |> Enum.with_index()
          |> Enum.map(fn {coeff, index} ->
            threshold = Float.round(coeff * total_sector_points * 2 * (1 / total_faction_count) * faction_weighting)
            threshold = Enum.max([threshold, index])
            Enum.min([threshold, total_sector_points])
          end)

        # population
        population_points = faction.population_points
        max_points_possible = state.inhabitable_systems_count * 16
        cap_by_player = 400

        population_thresholds =
          [0.0, 0.15, 0.3, 0.6]
          |> Enum.with_index()
          |> Enum.map(fn {coeff, index} ->
            threshold = Float.round(coeff * max_points_possible * faction_weighting)
            threshold = Enum.max([threshold, index])
            Enum.min([threshold, cap_by_player * coeff * faction.player_count + index])
          end)

        # visibility
        visibility_points = faction.visibility_count
        max_visibility_points = foreign_possessions * 5

        visibility_thresholds =
          [0.0, 0.3, 0.8, 0.98]
          |> Enum.with_index()
          |> Enum.map(fn {coeff, index} ->
            threshold = Float.round(coeff * max_visibility_points * 2 * (1 / total_faction_count) * faction_weighting)
            threshold = Enum.max([threshold, index])
            Enum.min([threshold, max_visibility_points + index])
          end)

        # final points
        threshold_values = [0, 2, 5, 10]
        conquest_index = length(Enum.filter(conquest_thresholds, fn t -> conquest_points >= t end)) - 1
        population_index = length(Enum.filter(population_thresholds, fn t -> population_points >= t end)) - 1
        visibility_index = length(Enum.filter(visibility_thresholds, fn t -> visibility_points >= t end)) - 1

        victory_points =
          Enum.at(threshold_values, conquest_index) + Enum.at(threshold_values, population_index) +
            Enum.at(threshold_values, visibility_index)

        %{
          faction
          | conquest_track: %{points: conquest_points, index: conquest_index, milestones: conquest_thresholds},
            population_track: %{points: population_points, index: population_index, milestones: population_thresholds},
            visibility_track: %{points: visibility_points, index: visibility_index, milestones: visibility_thresholds},
            victory_points: victory_points
        }
      end)

    %{state | factions: factions}
  end

  defp any_connected_players?(%{factions: factions, instance_id: instance_id}) do
    all_faction_channels_empty =
      factions
      |> Enum.map(fn %{id: faction_id} ->
        FactionChannel.topic(%{instance_id: instance_id, faction_id: faction_id})
        |> Portal.Presence.list()
        |> Enum.empty?()
      end)
      |> Enum.all?()

    not all_faction_channels_empty
  end
end
