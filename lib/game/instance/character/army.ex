defmodule Instance.Character.Army do
  use TypedStruct

  alias Instance.Character

  @valid_reactions [:flee, :fight_back, :defend, :attack_enemies, :attack_everyone]
  @army_repair_factor 0.4

  def jason(), do: []

  typedstruct enforce: true do
    field(:tiles, [%Character.Tile{}])
    field(:reaction, :flee | :fight_back | :defend | :attack_enemies | :attack_everyone)
    field(:maintenance, %Core.Value{}, default: Core.Value.new())
    field(:repair_coef, %Core.Value{}, default: Core.Value.new())
    field(:invasion_coef, %Core.Value{}, default: Core.Value.new())
    field(:raid_coef, %Core.Value{}, default: Core.Value.new())
  end

  def new(instance_id) do
    constant = Data.Querier.one(Data.Game.Constant, instance_id, :main)
    tiles = Enum.map(1..constant.army_tile_count, &Character.Tile.new/1)
    %Character.Army{tiles: tiles, reaction: :defend}
  end

  def convert_from_battle(%Character.Army{} = pre_fight_army, %Fight.Army{} = post_fight_army) do
    tiles =
      Enum.map(pre_fight_army.tiles, fn pre_fight_tile ->
        new_tile = Enum.find(post_fight_army.tiles, fn t -> t.id == pre_fight_tile.id end)
        Character.Tile.convert_from_battle(pre_fight_tile, new_tile)
      end)

    %{pre_fight_army | tiles: tiles}
  end

  def tile_empty?(%Character.Army{} = state, tile_id) do
    tile = Enum.find(state.tiles, fn tile -> tile.id == tile_id end)
    not is_nil(tile) and tile.ship_status == :empty
  end

  def tile_planned?(%Character.Army{} = state, tile_id) do
    tile = Enum.find(state.tiles, fn tile -> tile.id == tile_id end)
    not is_nil(tile) and tile.ship_status == :planned
  end

  def has_planned_ship?(%Character.Army{} = state),
    do: Enum.any?(state.tiles, fn tile -> tile.ship_status == :planned end)

  def has_ship?(%Character.Army{} = state),
    do: Enum.any?(state.tiles, fn tile -> tile.ship_status == :filled end)

  def has_colonization_ship?(%Character.Army{} = state),
    do: Enum.any?(state.tiles, fn tile -> not is_nil(tile.ship) and tile.ship.key == :transport_1 end)

  def plan_ship(%Character.Army{} = state, tile_id, ship_data, name),
    do: update_tile(state, tile_id, fn tile -> Character.Tile.plan_ship(tile, ship_data, name) end)

  def unplan_ship(%Character.Army{} = state, tile_id),
    do: update_tile(state, tile_id, fn tile -> Character.Tile.unplan_ship(tile) end)

  def put_ship(%Character.Army{} = state, tile_id, initial_xp, constant),
    do: update_tile(state, tile_id, fn tile -> Character.Tile.put_ship(tile, initial_xp, constant) end)

  def remove_ship(%Character.Army{} = state, tile_id),
    do: update_tile(state, tile_id, fn tile -> Character.Tile.remove_ship(tile) end)

  def update_reaction(%Character.Army{} = state, reaction) do
    if Enum.member?(@valid_reactions, reaction),
      do: %{state | reaction: reaction},
      else: state
  end

  def unplan_all_ships(%Character.Army{} = state) do
    tiles =
      Enum.map(state.tiles, fn tile ->
        if tile.ship_status == :planned,
          do: Character.Tile.unplan_ship(tile),
          else: tile
      end)

    %{state | tiles: tiles}
  end

  def compute_total_pv(%Character.Army{} = state) do
    Enum.reduce(state.tiles, 0, fn tile, pv -> pv + Character.Tile.total_hull(tile) end)
  end

  # try to damage {total_pv_to_remove} to the entier army
  # we do 4 run
  # in each run, we try to remove 25% life point to each units in army
  # until we run out of pv_to_remove
  def damage(%Character.Army{} = state, instance_id, total_pv_to_remove) do
    {tiles, _, logs} =
      Enum.reduce(1..4, {state.tiles, total_pv_to_remove, []}, fn i, {tiles, rest_pv_to_remove, logs} ->
        Enum.reduce(tiles, {[], rest_pv_to_remove, logs}, fn tile, {tiles, rest_pv_to_remove, logs} ->
          cond do
            rest_pv_to_remove <= 0 ->
              {tiles ++ [tile], rest_pv_to_remove, logs}

            tile.ship_status == :filled ->
              ship_data = Data.Querier.one(Data.Game.Ship, instance_id, tile.ship.key)

              before_damage_pv = Character.Ship.total_hull(tile.ship)
              damage = Enum.min([rest_pv_to_remove, ship_data.unit_hull * 0.25])

              ship = Character.Ship.damage(tile.ship, damage)
              tile = %{tile | ship: ship}

              after_damage_pv = Character.Ship.total_hull(tile.ship)
              actual_damage = before_damage_pv - after_damage_pv
              rest_pv_to_remove = rest_pv_to_remove - actual_damage

              {tile, logs} =
                cond do
                  Character.Ship.is_destroyed(ship) ->
                    tile = Character.Tile.remove_ship(tile)
                    {tile, logs ++ [:lost_ship]}

                  i == 1 and actual_damage > 0 ->
                    {tile, logs ++ [:damaged_ship]}

                  true ->
                    {tile, logs}
                end

              {tiles ++ [tile], rest_pv_to_remove, logs}

            true ->
              {tiles ++ [tile], rest_pv_to_remove, logs}
          end
        end)
      end)

    {%{state | tiles: tiles}, logs}
  end

  def sabotage(%Character.Army{} = state, instance_id, pv_target) do
    # keep only targetable tiles
    destroyable_tiles = Enum.filter(state.tiles, fn tile -> tile.ship_status == :filled end)

    if not Enum.empty?(destroyable_tiles) do
      # targeted tile
      tile = Game.call(instance_id, :rand, :master, {:random, destroyable_tiles})

      # damage of kill the targeted tile
      {state, logs, effective_damages} =
        if Character.Tile.total_hull(tile) < pv_target do
          total_hull = Character.Tile.total_hull(tile)
          {Character.Army.remove_ship(state, tile.id), [:lost_ship], total_hull}
        else
          tile = %{tile | ship: Character.Ship.damage(tile.ship, pv_target)}
          {update_tile(state, tile.id, fn _ -> tile end), [:damaged_ship], pv_target}
        end

      around =
        case Integer.mod(tile.id, 3) do
          0 -> [-1, 2, 3, -3, -4]
          1 -> [1, -2, -3, 3, 4]
          2 -> [1, -1, 2, -2, 3, -3, -4, 4]
        end
        |> Enum.map(&(&1 + tile.id))

      {tiles, logs} =
        state.tiles
        |> Enum.reduce({[], logs}, fn tile, {tiles, logs} ->
          if tile.id in around and tile.ship_status == :filled do
            blast = effective_damages * 0.1

            if Character.Tile.total_hull(tile) < blast do
              {tiles ++ [Character.Tile.remove_ship(tile)], [:lost_ship | logs]}
            else
              ship = Character.Ship.damage(tile.ship, blast)
              {tiles ++ [%{tile | ship: ship}], [:damaged_ship | logs]}
            end
          else
            {tiles ++ [tile], logs}
          end
        end)

      {%{state | tiles: tiles}, logs}
    else
      {state, []}
    end
  end

  def repair(%Character.Army{} = state, instance_id, elapsed_time) do
    repair_hull_point = state.repair_coef.value * @army_repair_factor * elapsed_time

    if repair_hull_point > 0 do
      ships_missing_hull =
        Enum.map(state.tiles, fn tile ->
          if tile.ship_status == :filled do
            ship_data = Data.Querier.one(Data.Game.Ship, instance_id, tile.ship.key)
            total_hull = ship_data.unit_count * ship_data.unit_hull
            {total_hull - Character.Ship.total_hull(tile.ship), ship_data}
          else
            {0, nil}
          end
        end)

      total_missing_hull = Enum.reduce(ships_missing_hull, 0, fn {missing_hull, _}, acc -> acc + missing_hull end)

      if total_missing_hull > 0 do
        repair_ratio = repair_hull_point / total_missing_hull
        repair_ratio = if repair_ratio > 1, do: 1.0, else: repair_ratio

        tiles =
          Enum.map(state.tiles, fn tile ->
            if tile.ship_status == :filled do
              {missing_hull, ship_data} = Enum.at(ships_missing_hull, tile.id - 1)
              new_hull = missing_hull * repair_ratio
              ship = Character.Ship.repair(tile.ship, new_hull, missing_hull, ship_data)

              %{tile | ship: ship}
            else
              tile
            end
          end)

        %{state | tiles: tiles}
      else
        state
      end
    else
      state
    end
  end

  def consume_colonization_ship(%Character.Army{} = state) do
    index = Enum.find_index(state.tiles, fn tile -> not is_nil(tile.ship) and tile.ship.key == :transport_1 end)
    tile = Enum.find(state.tiles, fn tile -> not is_nil(tile.ship) and tile.ship.key == :transport_1 end)

    tiles = List.replace_at(state.tiles, index, Character.Tile.remove_ship(tile))
    %{state | tiles: tiles}
  end

  defp update_tile(%Character.Army{} = state, tile_id, func) do
    %{state | tiles: Enum.map(state.tiles, fn tile -> if tile.id == tile_id, do: func.(tile), else: tile end)}
  end

  def compute_bonus(%Character.Army{} = state, instance_id, bonuses) do
    keys = [:maintenance, :repair_coef, :invasion_coef, :raid_coef]

    # initial state
    initial = Enum.reduce(keys, %{}, fn key, acc -> Map.put(acc, key, Core.Value.new()) end)

    # bonus from ships
    data =
      Enum.reduce(state.tiles, initial, fn tile, acc ->
        if tile.ship_status == :filled do
          ship_data = Data.Querier.one(Data.Game.Ship, instance_id, tile.ship.key)
          ship_max_hull = ship_data.unit_hull * ship_data.unit_count
          coeff = Character.Ship.total_hull(tile.ship) / ship_max_hull * ship_data.unit_count

          acc
          |> Map.update!(
            :maintenance,
            &Core.Value.add(&1, :ship, Core.ValuePart.new(tile.ship.key, ship_data.maintenance_cost))
          )
          |> Map.update!(
            :repair_coef,
            &Core.Value.add(&1, :ship, Core.ValuePart.new(tile.ship.key, ship_data.unit_repair_coef * coeff))
          )
          |> Map.update!(
            :invasion_coef,
            &Core.Value.add(&1, :ship, Core.ValuePart.new(tile.ship.key, ship_data.unit_invasion_coef * coeff))
          )
          |> Map.update!(
            :raid_coef,
            &Core.Value.add(&1, :ship, Core.ValuePart.new(tile.ship.key, ship_data.unit_raid_coef * coeff))
          )
        else
          acc
        end
      end)

    state =
      Enum.reduce(keys, state, fn key, acc ->
        Map.replace!(acc, key, Map.get(data, key))
      end)

    bonuses =
      Enum.map(bonuses, fn data ->
        %{
          reason: data.reason,
          bonus: data.bonus,
          from: Data.Querier.one(Data.Game.BonusPipelineIn, instance_id, data.bonus.from),
          to: Data.Querier.one(Data.Game.BonusPipelineOut, instance_id, data.bonus.to)
        }
      end)
      |> Enum.filter(fn bonus_data -> bonus_data.to.to == :army end)

    Core.Bonus.apply_bonuses(state, :army, bonuses)
  end
end
