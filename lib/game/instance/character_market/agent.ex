defmodule Instance.CharacterMarket.Agent do
  use Core.TickServer

  alias Instance.CharacterMarket.CharacterMarket
  alias Portal.Controllers.GlobalChannel

  @decorate tick()
  def on_call(:get_state, _, state) do
    {:reply, {:ok, state.data}, state}
  end

  @decorate tick()
  def on_call(:get_next_character_id, _, state) do
    {counter, data} = CharacterMarket.get_and_increment_character_counter(state.data)

    {:reply, {:ok, counter}, %{state | data: data}}
  end

  @decorate tick()
  def on_call({:sell_character, character_id}, _, state) do
    case CharacterMarket.sell_character(state.data, character_id) do
      {:ok, data, character} ->
        data = CharacterMarket.fill_empty_slots(data)
        GlobalChannel.broadcast_change(state.channel, %{global_character_market: data})

        {:reply, {:ok, character}, %{state | data: data}}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @decorate tick()
  def on_info(:tick, state) do
    {:noreply, state}
  end

  defp do_next_tick(state, next_tick) do
    {change, data} = CharacterMarket.next_tick(state.data, next_tick)

    if MapSet.member?(change, :update_market) do
      GlobalChannel.broadcast_change(state.channel, %{global_character_market: data})
    end

    {%{state | data: data}, CharacterMarket}
  end
end
