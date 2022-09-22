defmodule Fight.Manager do
  use TypedStruct

  alias Instance.Character.Character
  alias Fight.Ship

  @max_turn 100
  @turn_help_delay 2

  def fight([], _x), do: {:error, :missing_opponent}
  def fight(_x, []), do: {:error, :missing_opponent}
  def fight([], []), do: {:error, :missing_opponent}

  def fight(characters_left, characters_right) do
    # fetch useful data
    instance_id = List.first(characters_left).instance_id
    c = Data.Querier.one(Data.Game.Constant, instance_id, :main)
    ships_data = Data.Querier.all(Data.Game.Ship, instance_id)

    # check if one side has no ship, if yes, remove xp from fight
    left_has_no_ship = not Enum.any?(characters_left, &Character.has_ship?/1)
    right_has_no_ship = not Enum.any?(characters_right, &Character.has_ship?/1)
    is_null_xp_fight = left_has_no_ship and right_has_no_ship

    # prepare armies
    armies =
      Enum.map(characters_left, fn character ->
        Fight.Army.convert(character, :left, c, ships_data)
      end) ++
        Enum.map(characters_right, fn character ->
          Fight.Army.convert(character, :right, c, ships_data)
        end)

    # make fight
    battle =
      armies
      |> order_armies()
      |> prepare_battle()
      |> do_fight(instance_id)

    characters_left = convert_to_character(battle, characters_left, :left, is_null_xp_fight)
    characters_right = convert_to_character(battle, characters_right, :right, is_null_xp_fight)

    {{characters_left, characters_right}, battle.logs, battle.metadata, battle.victory}
  end

  # - take all armies (both sides)
  # - order armies by character's experience (desc)
  # - index armies according to their position in each sides
  defp order_armies(armies) do
    {armies, _} =
      armies
      |> Enum.sort(fn a, b -> a.experience >= b.experience end)
      |> Enum.map_reduce(%{left: 0, right: 0}, fn army, acc ->
        index = Map.get(acc, army.side)
        acc = Map.put(acc, army.side, index + 1)
        {%{army | delay: index * @turn_help_delay}, acc}
      end)

    armies
  end

  defp prepare_battle(armies) do
    # compute fight scale according to classes coeff
    fight_scale =
      Enum.reduce(armies, 0, fn army, armies_sum ->
        armies_sum +
          Enum.reduce(army.tiles, 0, fn tile, army_sum ->
            if tile.ship_status == :filled,
              do: army_sum + tile.ship.data.weight,
              else: army_sum
          end)
      end)

    %{
      initial: armies,
      final: armies,
      field: %{left: [], right: []},
      metadata: %{
        fight_scale: fight_scale,
        losses: %{left: 0, right: 0}
      },
      victory: :undefined,
      logs: [],
      current_logs: []
    }
  end

  defp convert_to_character(battle, characters, side, is_null_xp_fight) do
    Enum.map(characters, fn character ->
      army = Enum.find(battle.final, fn army -> army.id == character.id end)
      character = Character.convert_from_battle(character, army)

      status =
        cond do
          side == battle.victory -> :victorious
          not Character.has_ship?(character) -> :dead
          true -> :fleeing
        end

      # gained_xp is [6, 21]
      # we caped the maximum fight scale to 1000 (very big fight)
      # this value (1000) is strongly related to ships' weight data
      capped_fight_scale = Enum.min([battle.metadata.fight_scale, 1000])
      ratio_fight_scale = capped_fight_scale / 1000

      gained_xp =
        unless is_null_xp_fight,
          do: ratio_fight_scale * 15 + 6,
          else: 0

      {_, _, character} = Character.add_experience(character, gained_xp)

      character =
        if status == :dead,
          do: %{character | status: :dead},
          else: character

      {status, side, character}
    end)
  end

  defp do_fight(battle, instance_id, turn \\ 1) do
    # 1. transfer: take units from initial to field
    # 2. release target: ships with a target that is :destroyed, release it
    # 3. pick target: ships whitout target choose one on the opposite field
    # 4. fight
    # 5. cleaning: ships with status :destroyed or :escaping, are removed from the field
    # 6. check morale: ships with no morale put their status on :escaping
    # 7. outcome condition

    {outcome, battle} =
      battle
      |> do_transfer(turn, battle.initial)
      |> do_release_target()
      |> do_pick_target(instance_id)
      |> do_engage(battle.initial, instance_id)
      |> do_cleaning()
      |> do_check_morale()
      |> do_check_outcome(turn)

    cond do
      turn >= @max_turn -> do_cleaning(battle, true)
      outcome == :unresolved -> do_fight(battle, instance_id, turn + 1)
      outcome == :resolved -> do_cleaning(battle, true)
      true -> throw(:general_error)
    end
  end

  defp do_transfer(battle, _turn, []),
    do: battle

  defp do_transfer(battle, turn, [army | rest_armies]) do
    # fetch sendable ships from deck
    ships = Fight.Army.get_ready_ships(army, turn)

    # add transfer logs
    logs =
      Enum.map(ships, fn ship ->
        %{type: :transfer, source: Ship.ref(ship), data: %{target: :field, side: army.side}}
      end)

    battle = %{
      battle
      | field: Map.put(battle.field, army.side, Map.get(battle.field, army.side, []) ++ ships),
        current_logs: battle.current_logs ++ logs
    }

    do_transfer(battle, turn, rest_armies)
  end

  defp do_pick_target(battle, instance_id),
    do: %{
      battle
      | field: %{left: do_pick_target(battle, instance_id, :left), right: do_pick_target(battle, instance_id, :right)}
    }

  defp do_pick_target(battle, instance_id, side) do
    Enum.map(Map.fetch!(battle.field, side), fn ship ->
      if Fight.Ship.has_target?(ship) do
        ship
      else
        available_ships =
          Map.fetch!(battle.field, reverse(side))
          |> Enum.filter(fn s -> s.status != :destroyed end)

        if not Enum.empty?(available_ships) do
          random_ship = Game.call(instance_id, :rand, :master, {:random, available_ships})
          Fight.Ship.set_target(ship, random_ship.ref)
        else
          ship
        end
      end
    end)
  end

  defp do_release_target(battle),
    do: %{battle | field: %{left: do_release_target(battle, :left), right: do_release_target(battle, :right)}}

  defp do_release_target(battle, side) do
    Enum.map(Map.fetch!(battle.field, side), fn ship ->
      if Fight.Ship.has_target?(ship) do
        target = Enum.find(Map.fetch!(battle.field, reverse(side)), fn s -> s.ref == ship.target end)

        if target == nil or target.status == :destroyed,
          do: Fight.Ship.unset_target(ship),
          else: ship
      else
        ship
      end
    end)
  end

  defp do_engage(battle, [], _instance_id), do: battle

  defp do_engage(battle, _armies, instance_id) do
    left_side = Enum.map(battle.field.left, fn ship -> {ship, :left} end)
    right_side = Enum.map(battle.field.right, fn ship -> {ship, :right} end)

    sorted_ships =
      (left_side ++ right_side)
      |> Enum.sort(fn {a, _}, {b, _} -> a.morale >= b.morale end)

    Enum.reduce(sorted_ships, battle, fn {ship, side}, acc ->
      source = Enum.find(Map.fetch!(acc.field, side), fn s -> s.ref == ship.ref end)

      if source.target == nil or source.status != :alive do
        acc
      else
        target = Enum.find(Map.fetch!(acc.field, reverse(side)), fn s -> s.ref == ship.target end)

        if target.status == :destroyed do
          %{acc | current_logs: acc.current_logs ++ [%{type: :waiting, source: Ship.ref(source), data: %{}}]}
        else
          # engage
          {global_morale_loss, log, new_source, new_target} = Fight.Ship.engage(instance_id, source, target)

          # update source and target
          new_field =
            %{}
            |> Map.put(
              side,
              Enum.map(Map.fetch!(acc.field, side), fn s ->
                if s.ref == new_source.ref, do: new_source, else: s
              end)
            )
            |> Map.put(
              reverse(side),
              Enum.map(Map.fetch!(acc.field, reverse(side)), fn s ->
                new_ship = if s.ref == new_target.ref, do: new_target, else: s
                Fight.Ship.loose_morale(new_ship, global_morale_loss)
              end)
            )

          # add attack logs
          logs = [
            %{type: :attack, source: Ship.ref(new_source), data: %{target: Ship.ref(new_target), actions: log}}
          ]

          logs =
            logs ++
              if new_target.status == :destroyed,
                do: [%{type: :destroyed, source: Ship.ref(new_target), data: %{}}],
                else: []

          %{acc | field: new_field, current_logs: acc.current_logs ++ logs}
        end
      end
    end)
  end

  defp do_cleaning(battle, all \\ false) do
    left = splits_by_status(battle.field.left)
    right = splits_by_status(battle.field.right)

    types = [{:destroyed, left.destroyed ++ right.destroyed}, {:escaping, left.escaping ++ right.escaping}]
    types = if all, do: types ++ [{:alive, left.alive ++ right.alive}], else: types

    final =
      Enum.reduce(types, battle.final, fn {type, objects}, final ->
        Enum.reduce(objects, final, fn ship, final ->
          {army_id, tile_id} = ship.ref

          Enum.map(final, fn army ->
            if army.id == army_id do
              tiles =
                Enum.map(army.tiles, fn tile ->
                  if tile.id == tile_id,
                    do: Fight.Tile.update_ship(tile, if(type == :destroyed, do: nil, else: ship)),
                    else: tile
                end)

              %{army | tiles: tiles}
            else
              army
            end
          end)
        end)
      end)

    logs =
      Enum.reduce(types, [], fn {type, objects}, logs ->
        Enum.reduce(objects, logs, fn ship, logs ->
          case type do
            :alive -> logs ++ [%{type: :transfer, source: Ship.ref(ship), data: %{target: :army}}]
            :escaping -> logs ++ [%{type: :transfer, source: Ship.ref(ship), data: %{target: :army}}]
            :destroyed -> logs ++ [%{type: :cleaned_up, source: Ship.ref(ship), data: %{}}]
          end
        end)
      end)

    destroyed_by_side = [{:left, left.destroyed}, {:right, right.destroyed}]

    losses =
      Enum.reduce(destroyed_by_side, battle.metadata.losses, fn {side, objects}, losses ->
        Enum.reduce(objects, losses, fn ship, losses ->
          Map.put(losses, side, Map.fetch!(losses, side) + ship.data.weight)
        end)
      end)

    %{
      battle
      | final: final,
        field: %{left: left.alive, right: right.alive},
        current_logs: battle.current_logs ++ logs,
        metadata: %{battle.metadata | losses: losses}
    }
  end

  defp splits_by_status(side) do
    Enum.reduce(
      [:alive, :escaping, :destroyed],
      Enum.group_by(side, fn ship -> ship.status end),
      fn key, acc -> if Map.has_key?(acc, key), do: acc, else: Map.put(acc, key, []) end
    )
  end

  defp do_check_morale(battle) do
    battle
    |> check_morale(:left)
    |> check_morale(:right)
  end

  defp check_morale(battle, side) do
    {new_side, logs} =
      Enum.map_reduce(Map.fetch!(battle.field, side), [], fn ship, logs ->
        new_ship = Fight.Ship.set_escaping(ship)

        logs =
          logs ++
            if(ship.status != new_ship.status, do: [%{type: :escaping, source: Ship.ref(new_ship), data: %{}}], else: [])

        {new_ship, logs}
      end)

    %{battle | field: Map.put(battle.field, side, new_side), current_logs: battle.current_logs ++ logs}
  end

  defp do_check_outcome(battle, turn) do
    {outcome, battle} =
      Enum.reduce([:left, :right], {:unresolved, battle}, fn side, {outcome, battle} ->
        has_ships_on_field? = not Enum.empty?(Map.get(battle.field, side, []))

        has_reinforcement? =
          Enum.reduce(battle.initial, false, fn army, token ->
            if army.side == side and Fight.Army.has_reinforcement?(army, turn), do: true, else: token
          end)

        if not has_ships_on_field? and not has_reinforcement? do
          battle = %{
            battle
            | current_logs: battle.current_logs ++ [%{type: :victory, source: nil, data: %{side: reverse(side)}}],
              victory: reverse(side)
          }

          {:resolved, battle}
        else
          {outcome, battle}
        end
      end)

    # save logs
    battle = %{battle | logs: battle.logs ++ [battle.current_logs], current_logs: []}
    {outcome, battle}
  end

  defp reverse(:left), do: :right
  defp reverse(:right), do: :left
end
