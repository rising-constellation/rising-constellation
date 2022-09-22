defmodule Instance.Faction.Agent do
  use Core.TickServer

  alias Instance.Faction.Faction
  alias Instance.Faction.Character
  alias Instance.Faction.Market
  alias Instance.Faction.StellarSystem
  alias Portal.Controllers.FactionChannel

  require Logger

  @decorate tick()
  def on_call(:get_state, _from, state) do
    {:reply, {:ok, state.data}, state}
  end

  @decorate tick()
  def on_call({:get_system_state, system_id}, _, state) do
    case Game.call(state.instance_id, :stellar_system, system_id, :get_state) do
      {:ok, system} ->
        contact = Faction.resolve_system_visibility(state.data, system)
        obfuscated_system = StellarSystem.obfuscate(system, contact, state.data.id, state.instance_id)

        {:reply, obfuscated_system, state}

      error ->
        Logger.error(error)
        {:reply, :error, state}
    end
  end

  @decorate tick()
  def on_call({:get_character_state, character_id}, _, state) do
    with {:ok, character} <- Game.call(state.instance_id, :character, character_id, :get_state),
         {:ok, system} <- Game.call(state.instance_id, :stellar_system, character.system, :get_state) do
      visibility = Faction.resolve_character_visibility(state.data, system, character)
      obfuscated_character = Character.obfuscate(character, visibility)

      {:reply, obfuscated_character, state}
    else
      _error -> {:reply, :error, state}
    end
  end

  @decorate tick()
  def on_call({:get_system_informer_count, system_id}, _, state) do
    contacts = Faction.get_system_contact(state.data, system_id)
    informer = Map.get(contacts.details, :informer, [])
    {:reply, {:ok, length(informer)}, state}
  end

  @decorate tick()
  def on_call({:add_player, player}, _, state) do
    data = Faction.add_player(state.data, player)
    faction_data = Data.Querier.one(Data.Game.Faction, state.instance_id, state.data.key)

    FactionChannel.broadcast_change(state.channel, %{faction_faction: data})
    Game.cast(state.instance_id, :victory, :master, {:add_player, state.data.id})

    if state.speed != :fast do
      RC.PlayerEvents.create(%{
        type: "faction",
        key: "new_player",
        data: Jason.encode!(%{player: player.name, theme: faction_data.theme}),
        instance_id: state.instance_id,
        faction_id: state.data.id
      })
    end

    {:reply, :ok, %{state | data: data}}
  end

  @decorate tick()
  def on_call({:drop_explorer, system_id, player_name}, _, state) do
    {response, contact, data} = Faction.drop_system_explorer(state.data, system_id, player_name)
    system_and_contact = %{system_id: system_id, contact: contact}

    FactionChannel.broadcast_change(state.channel, %{faction_faction_contact: system_and_contact})
    Game.cast(state.instance_id, :galaxy, :master, {:update_contacts, data.key, data.contacts})

    {:reply, response, %{state | data: data}}
  end

  @decorate tick()
  def on_call({:drop_informer, system_id, player_name, count}, _, state) do
    {change, contact, data} = Faction.drop_system_informer(state.data, system_id, player_name, count)

    if MapSet.member?(change, :dropped) do
      system_and_contact = %{system_id: system_id, contact: contact}
      Game.cast(state.instance_id, :galaxy, :master, {:update_contacts, data.key, data.contacts})
      FactionChannel.broadcast_change(state.channel, %{faction_faction_contact: system_and_contact})
    end

    if MapSet.member?(change, :radar_update) do
      FactionChannel.broadcast_change(state.channel, %{faction_faction: data})
    end

    {:reply, :ok, %{state | data: data}}
  end

  @decorate tick()
  def on_call({:send_resources, from_player_id, to_player_id, resources}, _, state) do
    {action, result, state} = Market.send_resources(state, {from_player_id, to_player_id, resources})

    if result == :ok do
      name = Faction.get_player_name(state.data, from_player_id)
      notif = Notification.Text.new(:receive_resources, nil, %{player: name, resources: resources})
      Game.cast(state.instance_id, :player, to_player_id, {:push_notifs, notif})
    end

    FactionChannel.broadcast_change(state.channel, %{faction_faction: state.data})
    {action, result, state}
  end

  @decorate tick()
  def on_cast({:remove_informer, system_id}, state) do
    {change, data} = Faction.remove_informer(state.data, system_id)

    Game.cast(state.instance_id, :galaxy, :master, {:update_contacts, data.key, data.contacts})

    if MapSet.member?(change, :radar_update) do
      FactionChannel.broadcast_change(state.channel, %{faction_faction: data})
    end

    {:noreply, %{state | data: data}}
  end

  @decorate tick()
  def on_cast({:push_message, from, message}, state) do
    data = Faction.push_message(state.data, from, message)
    FactionChannel.broadcast_change(state.channel, %{faction_faction: data})

    {:noreply, %{state | data: data}}
  end

  def on_cast({:radar_update, system}, state) do
    data =
      case Faction.radar_update(state.data, system) do
        {:radar_update, data} ->
          FactionChannel.broadcast_change(state.channel, %{faction_faction: data})
          data

        {:no_radar_update, data} ->
          data
      end

    {:noreply, %{state | data: data}}
  end

  @decorate tick()
  def on_info(:tick, state) do
    {:noreply, state}
  end

  # TICK FUNCTIONS

  defp do_next_tick(state, next_tick) do
    {change, data} = Faction.next_tick(state.data, next_tick)

    if MapSet.member?(change, :update_object) do
      FactionChannel.broadcast_change(state.channel, %{detected_objects: data.detected_objects})
    end

    if MapSet.member?(change, :new_object_in_radar) do
      notif = Notification.Sound.new(:new_object_in_radar)
      FactionChannel.broadcast_change(state.channel, %{player_notifs: [notif]})
    end

    {%{state | data: data}, Faction}
  end
end
