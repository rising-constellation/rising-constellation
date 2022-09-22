defmodule Instance.Character.Actions.Jump do
  @moduledoc """
  Implementations of all `Instance.Character` action
  """
  alias Instance.Character.Action
  alias Instance.Character.ActionQueue
  alias Instance.Character.Character
  alias Instance.Character.Actions.Fight
  alias Instance.Character.Spy
  alias Spatial

  def pre_validate(character, %{"data" => data}) do
    unless Map.has_key?(data, "source") and Map.has_key?(data, "target"),
      do: throw(:bad_data)

    if character.type == :spy and Spy.discovered?(character.spy.cover.value, character.instance_id),
      do: throw(:unable_to_move)

    if character.action_status == :docking, do: throw(:unable_to_move)
    if character.actions.virtual_position == data["target"], do: throw(:same_position)
    if character.actions.virtual_position != data["source"], do: throw(:invalid_position)

    case Game.call(character.instance_id, :galaxy, :master, {:check_jump, data["source"], data["target"]}) do
      :invalid_jump ->
        throw(:invalid_jump)

      %{s1: s1, s2: s2, weight: distance} ->
        c = Data.Querier.one(Data.Game.Constant, character.instance_id, :main)
        travel_time = distance * c.character_movement_factor

        data =
          data
          |> Map.put("source_position", s1.position)
          |> Map.put("target_position", s2.position)

        ActionQueue.add(character.actions, {:jump, data, travel_time}, data["target"])
    end
  end

  def start(%Character{instance_id: instance_id} = character, %Action{} = action) do
    {:ok, _system} =
      Game.call(instance_id, :stellar_system, action.data["source"], {:remove_character, character, :on_board})

    character = Character.leave_system(character)

    if character.type == :admiral do
      Spatial.update(character, action)
    end

    {MapSet.new([:player_update]), [], character}
  end

  def finish(%Character{} = character, %Action{} = action) do
    instance_id = character.instance_id
    c = Data.Querier.one(Data.Game.Constant, instance_id, :main)

    # enter system
    {:ok, system} =
      Game.call(instance_id, :stellar_system, action.data["target"], {:push_character, character, :on_board})

    character = Character.enter_system(character, action.data["target"], action.data["target_position"])

    # check interception
    {character, interception_notifs, leaving_or_dead?} =
      Fight.check_interception(character, action, [:attack_enemies, :attack_everyone])

    # drop explorer
    {character, exploration_notifs} =
      if leaving_or_dead?,
        do: {character, []},
        else: drop_explorer(character, action, c)

    # all characters (except admirals, undercover spies and own faction characters)
    # announce their arrival or passage
    unless character.type == :admiral or (character.type == :spy and Spy.undercover?(character.spy, instance_id)) or
             system.owner == nil or (system.owner != nil and character.owner.faction_id == system.owner.faction_id) do
      data = %{type: character.type, player: character.owner.name, system: system.name}

      notif =
        if Instance.Character.ActionQueue.empty?(character.actions),
          do: Notification.Text.new(:foreign_agent_stopped, system.id, data),
          else: Notification.Text.new(:foreign_agent_passed, system.id, data)

      Game.cast(instance_id, :player, system.owner.id, {:push_notifs, notif})
    end

    # assemble notifs
    notifs = interception_notifs ++ exploration_notifs

    {MapSet.new([:player_update]), notifs, character}
  end

  defp drop_explorer(%Character{} = character, %Action{} = action, c) do
    call = {:drop_explorer, action.data["target"], character.owner.name}

    {character, notifs} =
      case Game.call(character.instance_id, :faction, character.owner.faction_id, call) do
        :dropped ->
          {_, notifs, character} = Character.add_experience(character, c.drop_explorer_xp)
          {character, notifs}

        :already_dropped ->
          {character, []}
      end

    {character, notifs}
  end
end
