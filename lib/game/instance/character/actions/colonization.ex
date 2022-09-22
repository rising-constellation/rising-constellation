defmodule Instance.Character.Actions.Colonization do
  @moduledoc """
  Implementations of all `Instance.Character` action
  """
  alias Instance.Character.Action
  alias Instance.Character.ActionQueue
  alias Instance.Character.Character
  alias Instance.Character.Actions.Fight

  def pre_validate(character, %{"data" => data}) do
    unless Map.has_key?(data, "target"), do: throw(:bad_data)

    if character.action_status == :docking, do: throw(:unable_to_move)
    if character.type != :admiral, do: throw(:invalid_character_type)
    if character.actions.virtual_position != data["target"], do: throw(:invalid_position)

    if Queue.any?(character.actions.queue, fn a -> a.type == :colonization and a.data["target"] == data["target"] end),
      do: throw(:no_multiple_colonization)

    ActionQueue.add(character.actions, {:colonization, data, :unknown_yet}, data["target"])
  end

  def start(%Character{} = character, %Action{} = action) do
    iid = character.instance_id
    c = Data.Querier.one(Data.Game.Constant, iid, :main)

    {:ok, player} = Game.call(iid, :player, character.owner.id, :get_state)
    {:ok, system} = Game.call(iid, :stellar_system, character.system, :get_state)

    {:ok, takeability} =
      Game.call(iid, :galaxy, :master, {:check_system_takeability, character.system, character.owner.faction})

    notif = Notification.Text.new(:colonization_cancelled, system.id, %{admiral: character.name, system: system.name})

    unless Instance.Player.Player.available_system_slot?(player), do: throw({:no_available_system_slot, [notif]})
    unless Character.has_colonization_ship?(character), do: throw({:no_colonization_ship, [notif]})
    unless system.status == :uninhabited, do: throw({:system_not_colonizable, [notif]})
    if takeability == :untakeable, do: throw({:system_not_takeable, [notif]})
    if system.siege != nil, do: throw({:no_action_under_siege, [notif]})

    # check interception
    {character, interception_notifs, fleeing_or_dead?} =
      Fight.check_interception(character, action, [:defend, :attack_enemies, :attack_everyone])

    # interception outcome
    {character, colonization_notifs} =
      unless fleeing_or_dead? do
        # start colonization
        actions =
          character.actions
          |> ActionQueue.map(fn a ->
            # `action` already has `started_at` and `cumulated_pauses` while `a` doesn't
            if Map.drop(a, [:started_at, :cumulated_pauses]) == Map.drop(action, [:started_at, :cumulated_pauses]),
              do: Action.reset_time(a, c.colonization_time),
              else: a
          end)

        character =
          %{character | actions: actions}
          |> Character.start_action(:colonization)

        notif = Notification.Text.new(:colonization_started, system.id, %{admiral: character.name, system: system.name})
        {character, [notif]}
      else
        # character = Character.abort_action(character)
        {character, []}
      end

    # assemble notifs
    notifs = interception_notifs ++ colonization_notifs

    {MapSet.new([:player_update]), notifs, character}
  end

  def finish(%Character{} = character, %Action{} = action) do
    iid = character.instance_id
    prev_character = character
    c = Data.Querier.one(Data.Game.Constant, iid, :main)

    {:ok, player} = Game.call(iid, :player, character.owner.id, :get_state)
    {:ok, system} = Game.call(iid, :stellar_system, character.system, :get_state)

    {:ok, takeability} =
      Game.call(iid, :galaxy, :master, {:check_system_takeability, character.system, character.owner.faction})

    has_system_slot = Instance.Player.Player.available_system_slot?(player)
    has_colonization_ship = Character.has_colonization_ship?(character)
    target_free = system.status == :uninhabited

    if takeability == :takeable and has_system_slot and has_colonization_ship and target_free do
      Game.cast(iid, :player, character.owner.id, {:claim_system, action.data["target"]})
      {_, _, character} = Character.add_experience(character, c.character_base_action_xp)

      character =
        character
        |> Character.consume_colonization_ship()
        |> Character.finish_action()

      notif = create_notif({prev_character, character}, system)

      {MapSet.new([:player_update]), [notif], character}
    else
      notif = Notification.Text.new(:colonization_cancelled, system.id, %{admiral: character.name, system: system.name})
      character = Character.finish_action(character)

      {MapSet.new([:player_update]), [notif], character}
    end
  end

  defp create_notif({prev_attacker, attacker}, system) do
    notif_data = %{
      system: Notification.System.convert(system),
      admiral: Notification.Character.diff(prev_attacker, attacker)
    }

    Notification.Box.new(:colonization, system.id, notif_data)
  end
end
