defmodule Instance.Character.Actions.EncourageHate do
  @moduledoc """
  Implementations of all `Instance.Character` action
  """
  alias Instance.Character.Action
  alias Instance.Character.ActionQueue
  alias Instance.Character.Character
  alias Instance.Character.Speaker

  def pre_validate(character, %{"data" => data}) do
    unless Map.has_key?(data, "target"), do: throw(:bad_data)

    if character.type != :speaker, do: throw(:invalid_character_type)
    if character.actions.virtual_position != data["target"], do: throw(:invalid_position)
    if Speaker.locked?(character.speaker), do: throw(:locked_character)
    if Queue.any?(character.actions.queue, fn a -> a.type == :encourage_hate end), do: throw(:no_similar_action)

    ActionQueue.add(character.actions, {:encourage_hate, data, :unknown_yet}, data["target"])
  end

  def start(%Character{} = character, %Action{} = action) do
    c = Data.Querier.one(Data.Game.Constant, character.instance_id, :main)

    {:ok, system} = Game.call(character.instance_id, :stellar_system, character.system, :get_state)

    notif = Notification.Text.new(:encourage_hate_cancelled, system.id, %{speaker: character.name, system: system.name})
    if Speaker.locked?(character.speaker), do: throw({:locked_character, [notif]})

    if system.owner != nil and system.owner.id == character.owner.id,
      do: throw({:no_encourage_hate_on_yourself, [notif]})

    # start encourage_hate
    actions =
      character.actions
      |> ActionQueue.map(fn a ->
        # `action` already has `started_at` and `cumulated_pauses` while `a` doesn't
        if Map.drop(a, [:started_at, :cumulated_pauses]) == Map.drop(action, [:started_at, :cumulated_pauses]),
          do: Action.reset_time(a, c.encourage_hate_time),
          else: a
      end)

    character =
      %{character | actions: actions}
      |> Character.start_action(:encourage_hate)

    notif = Notification.Text.new(:encourage_hate_started, system.id, %{speaker: character.name, system: system.name})

    {MapSet.new([:player_update]), [notif], character}
  end

  def finish(%Character{} = character, %Action{} = _action) do
    instance_id = character.instance_id
    prev_character = character

    c = Data.Querier.one(Data.Game.Constant, instance_id, :main)

    {:ok, system} = Game.call(instance_id, :stellar_system, character.system, :get_state)

    is_speaker_free = not Speaker.locked?(character.speaker)
    is_target_free = system.status in [:inhabited_neutral, :inhabited_dominion, :inhabited_player]
    is_not_own_system = system.owner == nil or system.owner.id != character.owner.id

    # compute result
    attack = character.speaker.encourage_hate_coef.value
    defense = Enum.max([system.happiness.value, 0])
    {result, {ratio, min, max, value}} = Core.Dice.roll(character.instance_id, attack, character.level, defense)

    {cooldown_duration, penalty, xp_factor} =
      case result do
        :critical_failure -> {120, 0, 0.1}
        :normal_failure -> {100, 5, 0.3}
        :normal_success -> {40, 15, 1}
        :critical_success -> {30, 20, 1.2}
      end

    if is_speaker_free and is_target_free and is_not_own_system do
      # remove happiness to owner
      if penalty > 0 do
        Game.cast(instance_id, :stellar_system, system.id, {:add_happiness_penalty, :encourage_hate, penalty})
      end

      # compute earned experience
      xp = c.character_base_action_xp * xp_factor
      {_, _, character} = Character.add_experience(character, xp)

      # set cooldown
      character = Character.set_cooldown(character, cooldown_duration)

      # finish action
      character = Character.finish_action(character)

      # create notifs
      notif_bop = %{attack: attack, defense: defense, ratio: ratio, result: value, min: min, max: max}
      {attacker_notif, defender_notif} = create_notifs({prev_character, character}, system, notif_bop, result, penalty)

      if defender_notif do
        Game.cast(character.instance_id, :player, system.owner.id, {:push_notifs, defender_notif})
      end

      {MapSet.new([:player_update]), [attacker_notif], character}
    else
      notif =
        Notification.Text.new(:encourage_hate_cancelled, system.id, %{speaker: character.name, system: system.name})

      {MapSet.new([:player_update]), [notif], Character.finish_action(character)}
    end
  end

  defp create_notifs({prev_attacker, attacker}, system, bop, result, penalty) do
    character_diff = Notification.Character.diff(prev_attacker, attacker)
    notif_system = Notification.System.convert(system)

    attacker_data = %{
      system: notif_system,
      side: :attacker,
      balance_of_power: bop,
      outcome: result,
      system_penalty: penalty,
      speaker: character_diff
    }

    attacker_notif = Notification.Box.new(:encourage_hate, system.id, attacker_data)

    defender_notif =
      if system.owner != nil do
        defender_data = %{
          system: notif_system,
          side: :defender,
          balance_of_power: bop,
          outcome: Core.Dice.reverse_result(result),
          system_penalty: penalty,
          speaker: character_diff
        }

        Notification.Box.new(:encourage_hate, system.id, defender_data)
      end

    {attacker_notif, defender_notif}
  end
end
