defmodule Instance.Character.Actions.Conversion do
  @moduledoc """
  Implementations of all `Instance.Character` action
  """
  alias Instance.Character.Action
  alias Instance.Character.ActionQueue
  alias Instance.Character.Character
  alias Instance.Character.Speaker

  def pre_validate(character, %{"data" => data}) do
    unless Map.has_key?(data, "target"), do: throw(:bad_data)
    unless Map.has_key?(data, "target_character"), do: throw(:bad_data)

    if character.type != :speaker, do: throw(:invalid_character_type)
    if character.actions.virtual_position != data["target"], do: throw(:invalid_position)
    if Speaker.locked?(character.speaker), do: throw(:locked_character)
    if Queue.any?(character.actions.queue, fn a -> a.type == :conversion end), do: throw(:no_similar_action)

    ActionQueue.add(character.actions, {:conversion, data, 0}, data["target"])
  end

  def start(%Character{} = character, %Action{} = action) do
    instance_id = character.instance_id
    prev_character = character

    c = Data.Querier.one(Data.Game.Constant, instance_id, :main)

    if Speaker.locked?(character.speaker), do: throw({:locked_character, []})

    target =
      case Game.call(instance_id, :character, action.data["target_character"], :get_state) do
        {:ok, target} ->
          if target.system != action.data["target"], do: throw({:character_not_reachable, []})
          if target.owner.id == character.owner.id, do: throw({:cannot_attack_itself, []})

          target

        _ ->
          throw({:character_target_does_not_exist, []})
      end

    # get action system location
    {:ok, system} = Game.call(instance_id, :stellar_system, target.system, :get_state)

    # if target is from the same faction than the system, give half of ci for bonus
    defense =
      if not is_nil(system.owner) and system.owner.faction_id == target.owner.faction_id,
        do: target.determination + system.happiness.value,
        else: target.determination

    attack = character.speaker.conversion_coef.value
    {result, {ratio, min, max, value}} = Core.Dice.roll(character.instance_id, attack, character.level, defense)

    {cooldown_duration, success?, xp_factor} =
      case result do
        :critical_failure -> {220, false, 0.1}
        :normal_failure -> {180, false, 0.3}
        :normal_success -> {120, true, 1}
        :critical_success -> {100, true, 1.2}
      end

    # compute earned experience
    xp = c.character_base_action_xp * xp_factor
    {_, _, character} = Character.add_experience(character, xp)

    # kill the target
    if success? do
      :ok = Game.call(instance_id, :player, target.owner.id, {:assassinate_character, target.id})
      :ok = Game.call(instance_id, :player, character.owner.id, {:convert_character, target, system.id})
    end

    # set cooldown
    character = Character.set_cooldown(character, cooldown_duration)

    # create notifs
    bop = %{attack: attack, defense: defense, ratio: ratio, result: value, min: min, max: max}
    {attacker_notif, defender_notif} = create_notifs({prev_character, character}, target, system, bop, result)

    Game.cast(character.instance_id, :player, target.owner.id, {:push_notifs, defender_notif})
    {MapSet.new([:player_update]), [attacker_notif], character}
  end

  def finish(%Character{} = character, %Action{} = _action) do
    {MapSet.new([:player_update]), [], Character.finish_action(character)}
  end

  defp create_notifs({prev_attacker, attacker}, target, system, bop, result) do
    notif_system = Notification.System.convert(system)
    attacker_diff = Notification.Character.diff(prev_attacker, attacker)
    target = Notification.Character.convert(target)

    attacker_data = %{
      system: notif_system,
      side: :attacker,
      balance_of_power: bop,
      outcome: result,
      speaker: attacker_diff,
      target: target
    }

    defender_data = %{
      system: notif_system,
      side: :defender,
      balance_of_power: bop,
      outcome: Core.Dice.reverse_result(result),
      speaker: attacker_diff,
      target: target
    }

    attacker_notif = Notification.Box.new(:conversion, system.id, attacker_data)
    defender_notif = Notification.Box.new(:conversion, system.id, defender_data)

    {attacker_notif, defender_notif}
  end
end
