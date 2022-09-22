defmodule Instance.Character.Actions.Fight do
  @moduledoc """
  Implementations of all `Instance.Character` action
  """
  alias Instance.Character.Action
  alias Instance.Character.ActionQueue
  alias Instance.Character.Character

  def pre_validate(character, %{"data" => data}) do
    unless Map.has_key?(data, "target"), do: throw(:bad_data)
    unless Map.has_key?(data, "target_character"), do: throw(:bad_data)

    if character.type != :admiral, do: throw(:invalid_character_type)
    if character.actions.virtual_position != data["target"], do: throw(:invalid_position)

    ActionQueue.add(character.actions, {:fight, data, 0}, data["target"])
  end

  def start(%Character{} = character, %Action{} = action) do
    instance_id = character.instance_id

    {:ok, system} = Game.call(instance_id, :stellar_system, character.system, :get_state)

    target =
      case Game.call(instance_id, :character, action.data["target_character"], :get_state) do
        {:ok, target} ->
          if target.type != :admiral, do: throw({:character_type_not_valid, []})
          if target.system != action.data["target"], do: throw({:character_not_reachable, []})
          if target.owner.id == character.owner.id, do: throw({:cannot_attack_itself, []})

          target

        _ ->
          throw({:character_target_does_not_exist, []})
      end

    # fetch friends for fight
    # TODO: when implemented, check ennemies or allies
    # and make distinction between :attack_ennemies and :attack_everyone
    reactions = [:defend, :attack_enemies, :attack_everyone]

    attackers =
      case character.owner.faction != target.owner.faction do
        true -> fetch_admirals_in_system(system, character, reactions)
        _ -> []
      end

    defenders =
      case character.owner.faction != target.owner.faction do
        true -> fetch_admirals_in_system(system, target, reactions)
        _ -> []
      end

    # assemble admirals
    i_attackers = [character | attackers]
    i_defenders = [target | defenders]
    i_all = i_attackers ++ i_defenders

    # execute fight
    {{f_attackers, f_defenders}, logs, metadata, victory} = Fight.Manager.fight(i_attackers, i_defenders)

    f_all = f_attackers ++ f_defenders

    # handle target
    # {updated_defender, should_die?}
    u_defenders =
      Enum.map(f_defenders, fn {status, _side, defender} ->
        Game.call(instance_id, :player, defender.owner.id, {:fight_callback, status, defender})
      end)

    # handle attacker
    # {updated_attacker, should_die?}
    u_attackers =
      Enum.map(f_attackers, fn {status, _side, attacker} ->
        Game.call(instance_id, :player, attacker.owner.id, {:fight_callback, status, attacker})
      end)

    u_all = u_attackers ++ u_defenders

    # prepare report
    # TODO: compute "result" of the fight
    # it should be something like "huge defeat" or "brilliant victory"
    #  - ratio lost/killed
    #  - défaite, défaite de justesse, victoire à l'arrachée, victoire, ...

    report_data = {
      %{attackers: i_attackers, defenders: i_defenders},
      logs,
      Map.put(metadata, :system_name, system.name)
    }

    # send notifs to each players
    send_notifs_and_report(i_all, f_all, u_all, victory, system, report_data, instance_id)

    # remove characters_to_kill
    # sort the current character to last to kill it last
    u_all
    |> Enum.sort(fn {%Character{id: id}, _}, {_, _} -> id != character.id end)
    |> Enum.each(&kill_character/1)

    {attacker, _} =
      u_attackers
      |> Enum.find(fn {%Character{id: id}, _} -> id == character.id end)

    {attacker_status, _, _} =
      f_attackers
      |> Enum.find(fn {_, _, attacker} -> attacker.id == character.id end)

    {MapSet.new([:player_update, attacker_status]), [], attacker}
  end

  def finish(%Character{} = character, %Action{} = _action) do
    character = Character.finish_action(character)
    {MapSet.new([:player_update]), [], character}
  end

  def check_interception(%Character{type: :admiral} = character, %Action{} = action, reactions) do
    instance_id = character.instance_id
    constant = Data.Querier.one(Data.Game.Constant, instance_id, :main)

    # check if hostiles
    {:ok, system} = Game.call(instance_id, :stellar_system, action.data["target"], :get_state)

    # TODO: when implemented, check ennemies or allies
    # and make distinction between :attack_ennemies and :attack_everyone
    hostiles =
      system.characters
      |> Enum.filter(fn c -> c.type == :admiral and c.owner.faction != character.owner.faction end)
      |> Enum.map(fn c ->
        case Game.call(instance_id, :character, c.id, :get_state) do
          {:ok, resp} -> resp
          _ -> nil
        end
      end)
      |> Enum.filter(fn c ->
        c != nil and c.action_status in [:idle, :docking] and Enum.member?(reactions, c.army.reaction)
      end)

    # fight hostiles
    if not Enum.empty?(hostiles) do
      Enum.reduce(hostiles, {character, [], false}, fn c, {character, notifs, fleeing_or_dead?} ->
        unless fleeing_or_dead? do
          # if character wants to flee, try fleeing
          flee? =
            if character.army.reaction == :flee,
              do: Game.call(instance_id, :rand, :master, {:uniform}) < constant.fleeing_chance,
              else: false

          if flee? do
            # character is fleeing, reseting its actions
            target_id = Game.call(instance_id, :galaxy, :master, {:get_closest_system, character.system})

            character =
              character
              |> Character.flee(target_id)
              |> Character.cancel_all_ships()

            data = %{admiral: character.name, system: system.name}
            notif = Notification.Text.new(:interception_and_flight, system.id, data)

            # apply to system...
            Game.cast(instance_id, :stellar_system, character.system, {:cancel_ordered_ships, character.id})

            {character, [notif | notifs], true}
          else
            # character is facing interpectors
            data = %{"target" => character.system, "target_character" => c.id}
            action = Action.new({:fight, data, 0})

            {changes, _, character} =
              try do
                Instance.Character.Actions.Fight.start(character, action)
              catch
                _ -> {MapSet.new(), [], character}
              end

            fleeing_or_dead? = character.status == :dead or MapSet.member?(changes, :fleeing)
            {character, notifs, fleeing_or_dead?}
          end
        else
          {character, notifs, fleeing_or_dead?}
        end
      end)
    else
      {character, [], false}
    end
  end

  def check_interception(%Character{} = character, %Action{} = _action, _reactions),
    do: {character, [], false}

  defp kill_character({%Character{} = _character, false}),
    do: nil

  defp kill_character({%Character{} = character, true}) do
    # clean dead character...
    {:ok, _system} =
      Game.call(character.instance_id, :stellar_system, character.system, {:remove_character, character, :on_board})

    # ... and terminate process
    Instance.Manager.kill_child(character.instance_id, {character.instance_id, :character, character.id})
  end

  defp fetch_admirals_in_system(system, character, reactions) do
    system.characters
    |> Enum.filter(fn c ->
      c.id != character.id and c.type == :admiral and c.owner.faction == character.owner.faction
    end)
    |> Enum.map(fn c ->
      case Game.call(character.instance_id, :character, c.id, :get_state) do
        {:ok, resp} -> resp
        _ -> nil
      end
    end)
    |> Enum.filter(fn c ->
      c != nil and c.action_status == :idle and Enum.member?(reactions, c.army.reaction)
    end)
  end

  defp send_notifs_and_report(i_all, f_all, u_all, victory, system, report_data, instance_id) do
    {initials, logs, metadata} = report_data
    {:ok, galaxy} = Game.call(instance_id, :galaxy, :master, :get_state)

    # prepare characters' data for the notifications and reports
    notif_characters =
      Enum.map(i_all, fn initial ->
        # side -> attacker - defender
        {status, side, _} = Enum.find(f_all, fn {_, _, final} -> final.id == initial.id end)
        {updated, has_to_die?} = Enum.find(u_all, fn {updated, _} -> updated.id == initial.id end)

        %{
          status: status,
          side: side,
          has_died: has_to_die?,
          previous: Notification.Character.convert(initial),
          current: Notification.Character.convert(updated)
        }
      end)

    notif_system = Notification.System.convert(system)

    # send notif and report only once to each involved players
    notif_characters
    |> Enum.group_by(fn c -> c.previous.owner.id end)
    |> Enum.each(fn {player_id, [first_character | _rest_characters]} ->
      # fetch player data
      {:ok, player} = Game.call(instance_id, :player, player_id, :get_state)

      outcome =
        if first_character.side == victory,
          do: :victory,
          else: :defeat

      # save report
      metadata_report = %{
        system: notif_system.name,
        scale: metadata.fight_scale,
        result: first_character.status
      }

      report_id =
        if Instance.Galaxy.Galaxy.is_tutorial(galaxy) do
          nil
        else
          {:ok, report} =
            %{
              type: "fight",
              metadata: Jason.encode!(metadata_report),
              report: Jason.encode!(%{initial: initials, battle: logs}),
              registration_id: player.registration_id
            }
            |> RC.PlayerReports.create()

          report.id
        end

      # send notif
      notif_data = %{
        system: notif_system,
        scale: metadata.fight_scale,
        report_id: report_id,
        outcome: outcome,
        admirals: notif_characters
      }

      notif = Notification.Box.new(:fight, system.id, notif_data)
      Game.cast(instance_id, :player, player_id, {:push_notifs, notif})
    end)
  end
end
