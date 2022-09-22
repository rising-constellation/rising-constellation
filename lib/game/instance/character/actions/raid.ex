defmodule Instance.Character.Actions.Raid do
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

    has_same_raid =
      character.actions.queue
      |> Queue.to_list()
      |> Enum.any?(fn action ->
        action.type == :raid and action.data["target"] == data["target"]
      end)

    if has_same_raid, do: throw(:no_multiple_raid)

    ActionQueue.add(character.actions, {:raid, data, :unknown_yet}, data["target"])
  end

  def start(%Character{} = character, %Action{} = action) do
    c = Data.Querier.one(Data.Game.Constant, character.instance_id, :main)

    {:ok, player} = Game.call(character.instance_id, :player, character.owner.id, :get_state)
    {:ok, system} = Game.call(character.instance_id, :stellar_system, character.system, :get_state)
    notif = Notification.Text.new(:raid_cancelled, system.id, %{admiral: character.name, system: system.name})

    unless Enum.member?([:inhabited_player, :inhabited_dominion, :inhabited_neutral], system.status),
      do: throw({:system_not_raidable, [notif]})

    if system.owner != nil and system.owner.id == player.id, do: throw({:no_raid_on_yourself, [notif]})
    if system.siege != nil, do: throw({:no_raid_during_siege, [notif]})

    # check interception
    {character, interception_notifs, fleeing_or_dead?} =
      Fight.check_interception(character, action, [:defend, :attack_enemies, :attack_everyone])

    # interception outcome
    {character, raid_notifs} =
      unless fleeing_or_dead? do
        # compute raid time
        ratio = Core.Dice.ratio(character.army.raid_coef.value, system.defense.value)
        time = c.raid_time * Core.Dice.ratio_to_factor(ratio)

        # start raid
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
          |> Character.start_action(:raid)

        notif = Notification.Text.new(:raid_started, system.id, %{admiral: character.name, system: system.name})

        request = {:besiege, :raid, time, character.id}
        Game.cast(character.instance_id, :stellar_system, character.system, request)

        {character, [notif]}
      else
        # character = Character.abort_action(character)
        {character, []}
      end

    # assemble notifs
    notifs = interception_notifs ++ raid_notifs

    {MapSet.new([:player_update]), notifs, character}
  end

  def finish(%Character{} = character, %Action{} = _action) do
    c = Data.Querier.one(Data.Game.Constant, character.instance_id, :main)
    prev_character = character

    {:ok, system} = Game.call(character.instance_id, :stellar_system, character.system, :get_state)

    {:ok, defender} =
      if system.owner != nil,
        do: Game.call(character.instance_id, :player, system.owner.id, :get_state),
        else: {:ok, nil}

    attack = character.army.raid_coef.value
    defense = system.defense.value
    {result, {ratio, min, max, value}} = Core.Dice.roll(character.instance_id, attack, character.level, defense)

    {lost_population_chances, damaged_buildings_count, pv_factor, xp_factor} =
      case result do
        :critical_failure -> {0.00, 0, 12, 0.1}
        :normal_failure -> {0.05, 1, 10, 0.3}
        :normal_success -> {0.10, 5, 8, 1}
        :critical_success -> {0.20, 6, 6, 1.2}
      end

    # compute earned experience
    xp = c.character_base_action_xp * xp_factor
    {_, _, character} = Character.add_experience(character, xp)

    # make damage to army
    pv_to_remove = pv_factor * defense + (1 - ratio) * 0.1 * Character.compute_total_army_pv(character)
    {character, _army_logs} = Character.damage_army(character, pv_to_remove)

    # release siege (and apply damage to system)
    request = {:release_siege, lost_population_chances, damaged_buildings_count}
    {:ok, system, siege_logs} = Game.call(character.instance_id, :stellar_system, character.system, request)

    # finish action
    character = Character.finish_action(character)

    # if character has failed, make it flee
    character =
      if Enum.member?([:normal_failure, :critical_failure], result) do
        target_id = Game.call(character.instance_id, :galaxy, :master, {:get_closest_system, system.id})
        Character.flee(character, target_id)
      else
        character
      end

    # create notifs
    bop = %{attack: attack, defense: defense, ratio: ratio, result: value, min: min, max: max}

    {attacker_notif, defender_notif} =
      create_notifs({prev_character, character}, defender, system, bop, siege_logs, result)

    if defender_notif do
      Game.cast(character.instance_id, :player, system.owner.id, {:push_notifs, defender_notif})
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

    attacker_notif = Notification.Box.new(:raid, system.id, attacker_data)

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

        Notification.Box.new(:raid, system.id, defender_data)
      end

    {attacker_notif, defender_notif}
  end
end
