defmodule Instance.Victory.Agent do
  use Core.TickServer

  alias Instance.Victory.Victory
  alias Portal.Controllers.GlobalChannel

  @decorate tick()
  def on_call(:get_state, _from, state) do
    {:reply, {:ok, state.data}, state}
  end

  @decorate tick()
  def on_cast({:add_player, faction_id}, state) do
    {:noreply, %{state | data: Victory.add_player(state.data, faction_id)}}
  end

  @decorate tick()
  def on_cast({:update_systems, systems, players}, state) do
    data =
      state.data
      |> Victory.reset_player_count(players)
      |> Victory.update_systems(systems)

    {:noreply, %{state | data: data}}
  end

  @decorate tick()
  def on_cast({:update_visibility, faction_key, visibility_count, players}, state) do
    data =
      state.data
      |> Victory.reset_player_count(players)
      |> Victory.update_visibility(faction_key, visibility_count)

    {:noreply, %{state | data: data}}
  end

  @decorate tick()
  def on_cast({:update_sector, sector, players}, state) do
    data =
      state.data
      |> Victory.reset_player_count(players)
      |> Victory.update_sector(sector)

    {:noreply, %{state | data: data}}
  end

  # should go in other place
  @decorate tick()
  def on_cast({:remove_informer, system_id}, state) do
    # - iterate over factions
    # - for each faction, get the {count} of informer on the given system
    # - transform to a list of {count} atom {faction} (eg. [:ark, :ark, :ark])
    # - merge all list (eg. [:myrmezir, :ark, :ark, :ark])

    contacts =
      Enum.flat_map(state.data.factions, fn faction ->
        {:ok, count} = Game.call(state.instance_id, :faction, faction.id, {:get_system_informer_count, system_id})
        List.duplicate(faction.id, count)
      end)

    if not Enum.empty?(contacts) do
      faction_id = Game.call(state.instance_id, :rand, :master, {:random, contacts})
      Game.cast(state.instance_id, :faction, faction_id, {:remove_informer, system_id})
    end

    {:noreply, state}
  end

  # should go in other place
  @decorate tick()
  def on_cast({:radar_update, system}, state) do
    Enum.each(state.data.factions, fn faction ->
      Game.cast(state.instance_id, :faction, faction.id, {:radar_update, system})
    end)

    {:noreply, state}
  end

  @decorate tick()
  def on_info(:tick, state) do
    {:noreply, state}
  end

  defp do_next_tick(state, next_tick) do
    {change, data, export} = Victory.next_tick(state.data, next_tick)

    if MapSet.member?(change, :victory_update) do
      GlobalChannel.broadcast_change(state.channel, %{global_victory: data})
    end

    if MapSet.member?(change, :victory) do
      GlobalChannel.broadcast_change(state.channel, %{signal: :victory})

      # close registrations, free profiles
      {:ok, galaxy} = Game.call(state.instance_id, :galaxy, :master, :get_state)

      unless Instance.Galaxy.Galaxy.is_tutorial(galaxy) do
        state.instance_id
        |> RC.Instances.get_instance()
        |> RC.Instances.close_instance()

        RC.Instances.record_victory(export.ranking, export.victory_type)
        RC.Rankings.update_rankings(export.ranking)
      end
    end

    if MapSet.member?(change, :close_game) do
      GlobalChannel.broadcast_change(state.channel, %{signal: :close_game})

      # destroy instance supervisor
      {:ok, galaxy} = Game.call(state.instance_id, :galaxy, :master, :get_state)

      unless Instance.Galaxy.Galaxy.is_tutorial(galaxy) do
        instance = RC.Instances.get_instance(state.instance_id)
        RC.Instances.finish_instance(instance, instance.account_id)
        Instance.Manager.destroy(instance.id)
      end
    end

    {%{state | data: data}, Victory}
  end
end
