defmodule Instance.CharacterMarket.CharacterMarket do
  use TypedStruct

  alias Instance.CharacterMarket
  alias Instance.Character

  def jason(), do: [except: [:instance_id]]

  typedstruct enforce: true do
    field(:character_counter, integer())
    field(:slots, [any()])

    field(:instance_id, integer())
  end

  def new(instance_id) do
    character_data = Data.Querier.all(Data.Game.Character, instance_id)
    rank_data = Data.Querier.all(Data.Game.CharacterRank, instance_id)
    cooldown = Core.CooldownValue.new(0)

    slots =
      Enum.map(character_data, fn c ->
        set =
          Enum.map(rank_data, fn r ->
            set = Enum.map(1..r.size, fn _ -> %{nth: 0, cooldown: cooldown, character: nil} end)
            %{key: r.key, data: set}
          end)

        %{key: c.key, data: set}
      end)

    state = %CharacterMarket.CharacterMarket{
      character_counter: 1,
      slots: slots,
      instance_id: instance_id
    }

    fill_empty_slots(state)
  end

  def get_and_increment_character_counter(state) do
    counter = state.character_counter
    state = %{state | character_counter: state.character_counter + 1}

    {counter, state}
  end

  def compute_next_tick_interval(state) do
    {_slots, next_ticks} =
      update_slots_with_data(state.slots, [], fn _, _, slot, next_ticks ->
        {slot, [Core.CooldownValue.next_tick_interval(slot.cooldown) | next_ticks]}
      end)

    Enum.min([:never | next_ticks])
  end

  def fill_empty_slots(state) do
    constant = Data.Querier.one(Data.Game.Constant, state.instance_id, :main)

    {slots, counter} =
      update_slots_with_data(state.slots, state.character_counter, fn type, rank, slot, counter ->
        if slot.character == nil do
          {%{
             slot
             | nth: slot.nth + 1,
               cooldown: Core.CooldownValue.set(slot.cooldown, constant.market_cooldown_duration),
               character: Character.Character.new(counter, type.key, rank.key, slot.nth, state.instance_id)
           }, counter + 1}
        else
          {slot, counter}
        end
      end)

    %{state | slots: slots, character_counter: counter}
  end

  def sell_character(state, character_id) do
    {slots, character} =
      update_slots_with_data(state.slots, nil, fn _, _, slot, character ->
        if slot.character != nil and slot.character.id == character_id do
          character = slot.character
          slot = %{slot | cooldown: Core.CooldownValue.set(slot.cooldown, 0), character: nil}
          {slot, character}
        else
          {slot, character}
        end
      end)

    if character == nil,
      do: {:error, :character_unavailable},
      else: {:ok, %{state | slots: slots}, character}
  end

  def next_tick(state, elapsed_time) do
    {MapSet.new(), state}
    |> empty_old_character(elapsed_time)
  end

  defp empty_old_character({change, state}, elapsed_time) do
    {slots, change} =
      update_slots_with_data(state.slots, change, fn _, _, slot, change ->
        new_cooldown = Core.CooldownValue.next_tick(slot.cooldown, elapsed_time)

        if Core.CooldownValue.recently_unlocked?(slot.cooldown, new_cooldown) do
          {%{slot | cooldown: new_cooldown, character: nil}, MapSet.put(change, :update_market)}
        else
          {%{slot | cooldown: new_cooldown}, change}
        end
      end)

    state = fill_empty_slots(%{state | slots: slots})
    {change, state}
  end

  defp update_slots_with_data(slots, data, func) do
    Enum.reduce(slots, {[], data}, fn type, {state1, data1} ->
      {resp, data1} =
        Enum.reduce(type.data, {[], data1}, fn rank, {state2, data2} ->
          {resp, data2} =
            Enum.reduce(rank.data, {[], data2}, fn slot, {state3, data3} ->
              {slot, data3} = func.(type, rank, slot, data3)
              {List.flatten([state3, slot]), data3}
            end)

          {List.flatten([state2, %{rank | data: resp}]), data2}
        end)

      {List.flatten([state1, %{type | data: resp}]), data1}
    end)
  end
end
