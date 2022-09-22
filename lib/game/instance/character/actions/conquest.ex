defmodule Instance.Character.Actions.Conquest do
  @moduledoc """
  Implementations of all `Instance.Character` action
  """
  alias Instance.Character.Action
  alias Instance.Character.ActionQueue
  alias Instance.Character.Character
  alias Instance.Character.Actions.Fight

  def pre_validate(character, %{"data" => data}) do
    unless Map.has_key?(data, "target"), do: throw(:bad_data)

    if character.type != :admiral, do: throw(:invalid_character_type)
    if character.action_status == :docking, do: throw(:unable_to_move)
    if character.actions.virtual_position != data["target"], do: throw(:invalid_position)
    unless Instance.Character.Army.has_ship?(character.army), do: throw(:ships_required)

    has_same_conquest =
      character.actions.queue
      |> Queue.to_list()
      |> Enum.any?(fn action ->
        action.type == :conquest and action.data["target"] == data["target"]
      end)

    if has_same_conquest, do: throw(:no_multiple_conquest)

    ActionQueue.add(character.actions, {:conquest, data, :unknown_yet}, data["target"])
  end

  def start(%Character{} = character, %Action{} = action) do
    iid = character.instance_id
    c = Data.Querier.one(Data.Game.Constant, iid, :main)

    {:ok, player} = Game.call(iid, :player, character.owner.id, :get_state)
    {:ok, system} = Game.call(iid, :stellar_system, character.system, :get_state)

    {:ok, takeability} =
      Game.call(iid, :galaxy, :master, {:check_system_takeability, character.system, character.owner.faction})

    notif = Notification.Text.new(:conquest_cancelled, system.id, %{admiral: character.name, system: system.name})

    unless Instance.Player.Player.available_system_slot?(player), do: throw({:no_available_system_slot, [notif]})

    unless Enum.member?([:inhabited_player, :inhabited_dominion, :inhabited_neutral], system.status),
      do: throw({:system_not_conquestable, [notif]})

    if system.owner != nil and system.owner.id == player.id, do: throw({:no_conquest_on_yourself, [notif]})
    if system.siege != nil, do: throw({:impossible_conquest, [notif]})
    if takeability == :untakeable, do: throw({:system_not_takeable, [notif]})

    # check interception
    {character, interception_notifs, fleeing_or_dead?} =
      Fight.check_interception(character, action, [:defend, :attack_enemies, :attack_everyone])

    # interception outcome
    {character, conquest_notifs} =
      unless fleeing_or_dead? do
        # compute conquest time
        ratio = Core.Dice.ratio(character.army.invasion_coef.value, system.defense.value)
        time = c.conquest_time * Core.Dice.ratio_to_factor(ratio)

        # start conquest
        actions =
          character.actions
          |> ActionQueue.map(fn a ->
            # `action` already has `started_at` and `cumulated_pauses` while `a` doesn't
            if Map.drop(a, [:started_at, :cumulated_pauses]) == Map.drop(action, [:started_at, :cumulated_pauses]),
              do: Action.reset_time(a, time),
              else: a
          end)

        character =
          %{character | actions: actions}
          |> Character.start_action(:conquest)

        notif = Notification.Text.new(:conquest_started, system.id, %{admiral: character.name, system: system.name})

        request = {:besiege, :conquest, time, character.id}
        Game.cast(iid, :stellar_system, character.system, request)

        {character, [notif]}
      else
        # character = Character.abort_action(character)
        {character, []}
      end

    # assemble notifs
    notifs = interception_notifs ++ conquest_notifs

    {MapSet.new([:player_update]), notifs, character}
  end

  def finish(%Character{} = character, %Action{} = _action) do
    iid = character.instance_id
    prev_character = character
    c = Data.Querier.one(Data.Game.Constant, iid, :main)

    {:ok, player} = Game.call(iid, :player, character.owner.id, :get_state)
    {:ok, system} = Game.call(iid, :stellar_system, character.system, :get_state)

    {:ok, takeability} =
      Game.call(iid, :galaxy, :master, {:check_system_takeability, character.system, character.owner.faction})

    {:ok, defender} =
      if system.owner != nil,
        do: Game.call(iid, :player, system.owner.id, :get_state),
        else: {:ok, nil}

    attack = character.army.invasion_coef.value
    defense = system.defense.value
    {result, {ratio, min, max, value}} = Core.Dice.roll(iid, attack, character.level, defense)

    {lost_population_chances, damaged_buildings_count, system_taken?, pv_factor, xp_factor} =
      case result do
        :critical_failure -> {0.02, 0, false, 12, 0.25}
        :normal_failure -> {0.10, 2, false, 10, 0.8}
        :normal_success -> {0.20, 6, true, 8, 1.2}
        :critical_success -> {0.05, 2, true, 6, 1.5}
      end

    # compute earned experience
    xp = c.character_base_action_xp * xp_factor
    {_, _, character} = Character.add_experience(character, xp)

    # make damage to army
    pv_to_remove = pv_factor * defense + (1 - ratio) * 0.1 * Character.compute_total_army_pv(character)
    {character, _army_logs} = Character.damage_army(character, pv_to_remove)

    # release siege
    request = {:release_siege, lost_population_chances, damaged_buildings_count}
    {:ok, system, siege_logs} = Game.call(iid, :stellar_system, character.system, request)

    if takeability == :takeable and system_taken? and Instance.Player.Player.available_system_slot?(player) do
      # remove system from previous player
      if defender != nil do
        if system.status == :inhabited_dominion,
          do: Game.cast(iid, :player, system.owner.id, {:lose_dominion, system.id}),
          else: Game.cast(iid, :player, system.owner.id, {:lose_system, system.id})
      end

      # add new system to player
      Game.cast(iid, :player, character.owner.id, {:claim_system, system.id})
    end

    # finish action
    character = Character.finish_action(character)

    # if character has failed, make it flee
    character =
      if Enum.member?([:normal_failure, :critical_failure], result) do
        target_id = Game.call(iid, :galaxy, :master, {:get_closest_system, system.id})
        Character.flee(character, target_id)
      else
        character
      end

    # create notifs
    bop = %{attack: attack, defense: defense, ratio: ratio, result: value, min: min, max: max}

    {attacker_notif, defender_notif} =
      create_notifs({prev_character, character}, defender, system, bop, siege_logs, result)

    if defender_notif do
      Game.cast(iid, :player, system.owner.id, {:push_notifs, defender_notif})
    end

    {MapSet.new([:player_update]), [attacker_notif], character}
  end

  defp create_notifs({prev_attacker, attacker}, defender, system, bop, siege_logs, result) do
    notif_system = Notification.System.convert(system)
    attacker_diff = Notification.Character.diff(prev_attacker, attacker)

    attacker_data = %{
      system: notif_system,
      side: :attacker,
      balance_of_power: bop,
      siege_logs: siege_logs,
      outcome: result,
      admiral: attacker_diff
    }

    attacker_notif = Notification.Box.new(:conquest, system.id, attacker_data)

    defender_notif =
      if defender do
        defender_data = %{
          system: notif_system,
          side: :defender,
          balance_of_power: bop,
          siege_logs: siege_logs,
          outcome: Core.Dice.reverse_result(result),
          admiral: attacker_diff
        }

        Notification.Box.new(:conquest, system.id, defender_data)
      end

    {attacker_notif, defender_notif}
  end
end
