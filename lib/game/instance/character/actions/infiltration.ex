defmodule Instance.Character.Actions.Infiltrate do
  @moduledoc """
  Implementations of all `Instance.Character` action
  """
  alias Instance.Character.Action
  alias Instance.Character.ActionQueue
  alias Instance.Character.Character

  def pre_validate(character, %{"data" => data}) do
    unless Map.has_key?(data, "target"), do: throw(:bad_data)

    if character.type != :spy, do: throw(:invalid_character_type)
    if character.actions.virtual_position != data["target"], do: throw(:invalid_position)

    ActionQueue.add(character.actions, {:infiltrate, data, :unknown_yet}, data["target"])
  end

  def start(%Character{} = character, %Action{} = action) do
    c = Data.Querier.one(Data.Game.Constant, character.instance_id, :main)

    {:ok, system} = Game.call(character.instance_id, :stellar_system, character.system, :get_state)
    notif = Notification.Text.new(:infiltration_cancelled, system.id, %{spy: character.name, system: system.name})

    unless Enum.member?([:inhabited_neutral, :inhabited_dominion, :inhabited_player], system.status),
      do: throw({:system_not_infiltrable, [notif]})

    # compute infiltration time
    ratio = Core.Dice.ratio(character.spy.infiltrate_coef.value, system.counter_intelligence.value)
    time = c.infiltration_time * Core.Dice.ratio_to_factor(ratio)

    # start infiltration
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
      |> Character.start_action(:infiltration)

    notif = Notification.Text.new(:infiltration_started, system.id, %{spy: character.name, system: system.name})

    {MapSet.new([:player_update]), [notif], character}
  end

  def finish(%Character{} = character, %Action{} = action) do
    instance_id = character.instance_id
    prev_character = character
    c = Data.Querier.one(Data.Game.Constant, instance_id, :main)

    {:ok, system} = Game.call(instance_id, :stellar_system, character.system, :get_state)

    # compute result
    attack = character.spy.infiltrate_coef.value
    defense = system.counter_intelligence.value
    {result, {ratio, min, max, value}} = Core.Dice.roll(instance_id, attack, character.level, defense)

    {drop_contact_count, lost_cover, xp_factor} =
      case result do
        :critical_failure -> {0, 30..40, 0.1}
        :normal_failure -> {0, 20..30, 0.3}
        :normal_success -> {1, 8..12, 1}
        :critical_success -> {2, 4..8, 1.2}
      end

    # compute lost cover
    lost_cover = Game.call(instance_id, :rand, :master, {:random, lost_cover})

    # compute earned experience
    xp = c.character_base_action_xp * xp_factor
    {_, _, character} = Character.add_experience(character, xp)

    # drop informer
    if drop_contact_count > 0 do
      call = {:drop_informer, action.data["target"], character.owner.name, drop_contact_count}
      :ok = Game.call(instance_id, :faction, character.owner.faction_id, call)
    end

    # lose cover
    {character, became_discovered?} = Character.lose_cover(character, lost_cover)

    # if character become discovered, update stellar_system
    if became_discovered? do
      Game.cast(instance_id, :stellar_system, character.system, {:update_character, character})

      # send notification to owner of system
      if system.owner != nil do
        notif = Notification.Text.new(:foreign_spy_discovered, system.id, %{spy: character.name, system: system.name})
        Game.cast(instance_id, :player, system.owner.id, {:push_notifs, notif})
      end
    end

    # finish action
    character = Character.finish_action(character)

    # create notifs
    bop = %{attack: attack, defense: defense, ratio: ratio, result: value, min: min, max: max}
    notif = create_notif({prev_character, character}, system, bop, drop_contact_count, result)

    {MapSet.new([:player_update]), [notif], character}
  end

  defp create_notif({prev_attacker, attacker}, system, bop, drop_contact_count, result) do
    notif_system = Notification.System.convert(system)
    attacker_diff = Notification.Character.diff(prev_attacker, attacker, 6)

    notif_data = %{
      system: notif_system,
      side: :attacker,
      balance_of_power: bop,
      contact_count: drop_contact_count,
      outcome: result,
      spy: attacker_diff
    }

    Notification.Box.new(:infiltration, system.id, notif_data)
  end
end
