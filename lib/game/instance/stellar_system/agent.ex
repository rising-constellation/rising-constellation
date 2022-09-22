defmodule Instance.StellarSystem.Agent do
  use Core.TickServer

  alias Instance.StellarSystem.StellarSystem

  @decorate tick()
  def on_call(:get_state, _from, state) do
    {:reply, {:ok, state.data}, state}
  end

  def on_call(:get_position, _from, state) do
    {:reply, {:ok, state.data.position}, state}
  end

  def on_call({:order_building, "build", production_data}, _, state) do
    case StellarSystem.order_building_production(state.data, production_data) do
      {:ok, data} -> {:reply, {:ok, data}, %{state | data: data}}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  def on_call({:order_building, "repair", production_data}, _, state) do
    case StellarSystem.order_building_repairs(state.data, production_data) do
      {:ok, data} -> {:reply, {:ok, data}, %{state | data: data}}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  def on_call({:order_ship, production_data}, _, state) do
    with {character_id, _, _, _} <- production_data,
         {:ok, character} <- Game.call(state.instance_id, :character, character_id, :get_state),
         {:ok, data} <- StellarSystem.can_order_ship(state.data, production_data, character),
         {:ok, character} <- Game.call(state.instance_id, :character, character_id, {:order_ship, production_data}),
         {:ok, data} <- StellarSystem.order_ship_production(data, production_data, character) do
      {:reply, {:ok, character, data}, %{state | data: data}}
    else
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  @decorate tick()
  def on_call({:remove_building, production_data}, _, state) do
    case StellarSystem.remove_building(state.data, production_data) do
      {:ok, change, notifs, data} ->
        cast_hook(state.instance_id, {change, notifs, data})
        {:reply, {:ok, data}, %{state | data: data}}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @decorate tick()
  def on_call({:cancel_production, production_id}, _, state) do
    case StellarSystem.cancel_production(state.data, production_id) do
      {:ok, :building, credit, data} ->
        {:reply, {credit, 0, data}, %{state | data: data}}

      {:ok, :building_repairs, credit, data} ->
        {:reply, {credit, 0, data}, %{state | data: data}}

      {:ok, :ship, item, credit, technology, data} ->
        case Game.call(state.instance_id, :character, item.target_id, {:cancel_ship, item.tile_id}) do
          {:ok, _} ->
            {:reply, {credit, technology, data}, %{state | data: data}}

          {:error, reason} ->
            {:reply, {:error, reason}, state}
        end

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @decorate tick()
  def on_call({:claim, player, is_initial_system, is_dominion}, _, state) do
    data =
      case StellarSystem.claim(state.data, player, is_initial_system, is_dominion) do
        {:radar_update, data} ->
          Game.cast(state.instance_id, :victory, :master, {:radar_update, data})
          data

        {:no_radar_update, data} ->
          data
      end

    {:reply, data, %{state | data: data}}
  end

  @decorate tick()
  def on_call({:abandon}, _, state) do
    {:radar_update, data} = StellarSystem.abandon(state.data)
    Game.cast(state.instance_id, :victory, :master, {:radar_update, data})

    {:reply, data, %{state | data: data}}
  end

  @decorate tick()
  def on_call({:release_siege, lost_population_chances, damaged_buildings_chances}, _, state) do
    {data, logs} =
      state.data
      |> StellarSystem.release_siege()
      |> StellarSystem.raid(lost_population_chances, damaged_buildings_chances)

    if data.owner do
      case data.status do
        :inhabited_player -> Game.cast(data.instance_id, :player, data.owner.id, {:update_system, data})
        :inhabited_dominion -> Game.cast(data.instance_id, :player, data.owner.id, {:update_dominion, data})
        _ -> nil
      end
    end

    {:reply, {:ok, data, logs}, %{state | data: data}}
  end

  # Check if it's used
  @decorate tick()
  def on_call({:raid, lost_population_chances, lost_buildings_chances}, _, state) do
    data = StellarSystem.raid(state.data, lost_population_chances, lost_buildings_chances)

    {:reply, :ok, %{state | data: data}}
  end

  @decorate tick()
  def on_call({:update_bonuses, from, bonuses}, _, state) do
    {_, _, data} = StellarSystem.update_bonuses(state.data, from, bonuses)
    {:reply, data, %{state | data: data}}
  end

  @decorate tick()
  def on_call({:push_character, character, mode}, _, state) do
    {:ok, data} = StellarSystem.push_character(state.data, character, mode)
    {:reply, {:ok, data}, %{state | data: data}}
  end

  @decorate tick()
  def on_call({:remove_character, character, mode}, _, state) do
    {:ok, data} = StellarSystem.remove_character(state.data, character, mode)
    {:reply, {:ok, data}, %{state | data: data}}
  end

  @decorate tick()
  def on_cast({:update_character, character}, state) do
    {:ok, data} = StellarSystem.update_character(state.data, character)
    {:noreply, %{state | data: data}}
  end

  @decorate tick()
  def on_cast({:besiege, type, duration, character_id}, state) do
    data = StellarSystem.besiege(state.data, type, duration, character_id)
    notif = Notification.Text.new(:system_under_siege, data.id, %{system: data.name})

    if data.owner do
      case data.status do
        :inhabited_player -> Game.cast(data.instance_id, :player, data.owner.id, {:update_system, data})
        :inhabited_dominion -> Game.cast(data.instance_id, :player, data.owner.id, {:update_dominion, data})
        _ -> nil
      end

      Game.cast(state.instance_id, :player, data.owner.id, {:push_notifs, notif})
    end

    {:noreply, %{state | data: data}}
  end

  @decorate tick()
  def on_cast({:cancel_ordered_ships, character_id}, state) do
    data = StellarSystem.cancel_ordered_ships(state.data, character_id)

    if data.owner do
      Game.cast(state.instance_id, :player, data.owner.id, {:update_system, data})
    end

    {:noreply, %{state | data: data}}
  end

  @decorate tick()
  def on_cast({:add_happiness_penalty, reason, value}, state) do
    {change, notifs, data} = StellarSystem.add_happiness_penalty(state.data, reason, value)
    cast_hook(state.instance_id, {change, notifs, data})

    {:noreply, %{state | data: data}}
  end

  @decorate tick()
  def on_info(:tick, state) do
    {:noreply, state}
  end

  defp do_next_tick(state, next_tick) do
    {change, notifs, data} = StellarSystem.next_tick(state.data, next_tick)
    cast_hook(state.instance_id, {change, notifs, data})

    {%{state | data: data}, StellarSystem}
  end

  defp cast_hook(instance_id, {change, notifs, data}) do
    if MapSet.member?(change, :remove_contact) do
      Game.cast(instance_id, :victory, :master, {:remove_informer, data.id})
    end

    if MapSet.member?(change, :population_class_update) do
      Game.cast(instance_id, :galaxy, :master, {:update_system_population_class, data})
    end

    if data.owner != nil do
      if MapSet.member?(change, :player_update) do
        case data.status do
          :inhabited_player -> Game.cast(instance_id, :player, data.owner.id, {:update_system, data})
          :inhabited_dominion -> Game.cast(instance_id, :player, data.owner.id, {:update_dominion, data})
          _ -> nil
        end
      end

      if MapSet.member?(change, :radar_update) do
        Game.cast(instance_id, :victory, :master, {:radar_update, data})
      end

      if not Enum.empty?(notifs) do
        Game.cast(instance_id, :player, data.owner.id, {:push_notifs, notifs})
      end

      change
      |> Enum.filter(fn
        {:ship_built, _item, _initial_xp} -> true
        _ -> false
      end)
      |> Enum.each(fn {:ship_built, item, initial_xp} ->
        Game.cast(instance_id, :character, item.target_id, {:put_ship, item.tile_id, initial_xp})
      end)
    end
  end
end
