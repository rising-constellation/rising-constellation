defmodule Instance.Character.Agent do
  use Core.TickServer

  alias Instance.Character.Action
  alias Instance.Character.ActionImpl
  alias Instance.Character.Character

  require Logger

  # SERVER

  @decorate tick()
  def on_call(:get_state, _from, state) do
    {:reply, {:ok, state.data}, state}
  end

  def on_call({:add_actions, _}, _from, %{data: %Character{on_strike: true}} = state) do
    {:reply, {:error, :character_on_strike}, state}
  end

  @decorate tick()
  def on_call({:add_actions, actions}, _from, state) do
    data = Character.add_actions(state.data, actions, &ActionImpl.pre_validate_action/2)
    Game.cast(state.instance_id, :player, data.owner.id, {:update_character, data})

    {:reply, :ok, %{state | data: data}}
  end

  @decorate tick()
  def on_call(:flee, _from, state) do
    target_id = Game.call(state.instance_id, :galaxy, :master, {:get_closest_system, state.data.system})
    data = Character.flee(state.data, target_id)

    {:reply, data, %{state | data: data}}
  end

  @decorate tick()
  def on_call({:sabotage_army, target_pv}, _from, state) do
    if state.data.type == :admiral do
      data = Character.sabotage_army(state.data, target_pv)
      {:reply, {:ok, data}, %{state | data: data}}
    else
      {:reply, {:error, :error}, state}
    end
  end

  @decorate tick()
  def on_call({:order_ship, production_data}, _from, state) do
    case Character.order_ship(state.data, production_data) do
      {:ok, data} -> {:reply, {:ok, data}, %{state | data: data}}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  @decorate tick()
  def on_call({:cancel_ship, tile_id}, _from, state) do
    case Character.cancel_ship(state.data, tile_id) do
      {:ok, data} -> {:reply, {:ok, data}, %{state | data: data}}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  @decorate tick()
  def on_call({:destroy_ship, tile_id}, _from, state) do
    data = Character.remove_ship(state.data, tile_id)
    {:reply, {:ok, data}, %{state | data: data}}
  end

  @decorate tick()
  def on_call(:cancel_all_ships, _from, state) do
    data = Character.cancel_all_ships(state.data)
    {:reply, data, %{state | data: data}}
  end

  def on_call({:update_reaction, _}, _from, %{data: %Character{on_strike: true}} = state) do
    {:reply, {:error, :character_on_strike}, state}
  end

  @decorate tick()
  def on_call({:update_reaction, reaction}, _from, %{data: %{type: :admiral}} = state) do
    data = Character.update_reaction(state.data, reaction)
    {:reply, {:ok, data}, %{state | data: data}}
  end

  def on_call({:update_reaction, _reaction}, _from, state) do
    {:reply, {:error, :reaction_only_for_admirals}, state}
  end

  def on_call({:update_owner, player}, _from, state) do
    iid = state.instance_id
    data = state.data
    position = data.actions.virtual_position

    Game.call(iid, :stellar_system, position, {:remove_character, data, :on_board})
    data = Character.update_owner(data, player)
    Game.call(iid, :stellar_system, position, {:push_character, data, :on_board})

    {:reply, {:ok, data}, %{state | data: data}}
  end

  @decorate tick()
  def on_call({:update_strike, player_is_bankrupt}, _from, state) do
    data = Character.update_strike(state.data, player_is_bankrupt)
    {:reply, {:ok, data}, %{state | data: data}}
  end

  @decorate tick()
  def on_call({:update_bonuses, from, bonuses}, _, state) do
    data = Character.update_bonuses(state.data, from, bonuses)

    {:reply, data, %{state | data: data}}
  end

  def on_call(:get_position, _from, state) do
    instance_id = state.instance_id
    {position, angle} = Character.get_position(state.data, instance_id)

    {:reply, {:ok, {state.data, position, angle}}, state}
  end

  def on_call({:fix, systems}, _from, state) do
    {result, data} = Character.fix(state.data, systems)
    Game.cast(state.instance_id, :player, data.owner.id, {:update_character, data})

    {:reply, result, %{state | data: data}}
  end

  def on_call({:set_on_sold}, _from, state) do
    data = Character.set_on_sold(state.data)
    {:reply, {:ok, data}, %{state | data: data}}
  end

  def on_call({:unset_on_sold}, _from, state) do
    data = Character.unset_on_sold(state.data)
    {:reply, {:ok, data}, %{state | data: data}}
  end

  # called by orchestrator
  def on_call({:done, _hook_type, %Character{} = character}, _from, state) do
    ref = Process.send_after(self(), :tick, 0)
    tick = %{state.tick | time: Instance.Time.Time.now(state.tick.cumulated_pauses), ref: ref, running?: true}

    # agent state might have changed while orchestrator was doing its thing
    character =
      if state.data.on_strike and not character.on_strike do
        %{character | on_strike: state.data.on_strike}
      else
        character
      end

    {:reply, :ok, %{state | tick: tick, data: character}}
  end

  @decorate tick()
  def on_cast({:update_state, character}, state) do
    {:noreply, %{state | data: character}}
  end

  @decorate tick()
  def on_cast({:put_ship, tile_id, initial_xp}, state) do
    data = Character.put_ship(state.data, tile_id, initial_xp)
    Game.cast(state.instance_id, :player, data.owner.id, {:update_character, data})

    {:noreply, %{state | data: data}}
  end

  @decorate tick()
  def on_cast({:clear_actions, index}, state) do
    data = Character.clear_actions_after(state.data, index)
    Game.cast(state.instance_id, :player, data.owner.id, {:update_character, data})

    {:noreply, %{state | data: data}}
  end

  # called by orchestrator
  def orchestrated(:start, %Action{} = action, %Character{} = character) do
    {change, notifs, character} = ActionImpl.on_start(%Character{} = character, action)

    send_update(change, character)
    send_notifs(notifs, character)

    {:ok, character}
  end

  # called by orchestrator
  def orchestrated(:finish, %Action{} = action, %Character{} = character) do
    {change, notifs, character} = ActionImpl.on_finish(%Character{} = character, action)

    send_update(change, character)
    send_notifs(notifs, character)

    {:ok, character}
  end

  @decorate tick()
  def on_info(:tick, state) do
    {:noreply, state}
  end

  # TICK FUNCTIONS

  defp do_next_tick(state, next_tick) do
    {change, notifs, %Character{} = character} = Character.next_tick(state.data, next_tick, state.tick.cumulated_pauses)

    send_update(change, character)
    send_notifs(notifs, character)

    {%{state | data: character}, Character}
  end

  # PRIVATE FUNCTIONS

  defp send_notifs(notifs, %Character{} = character) do
    unless Enum.empty?(notifs),
      do: Game.cast(character.instance_id, :player, character.owner.id, {:push_notifs, notifs})
  end

  defp send_update(change, %Character{} = character) do
    if MapSet.member?(change, :player_update) and character.owner != nil do
      Game.cast(character.instance_id, :player, character.owner.id, {:update_character, character})
    end

    if MapSet.member?(change, :system_update) and character.system != nil do
      Game.cast(character.instance_id, :stellar_system, character.system, {:update_character, character})
    end
  end
end
