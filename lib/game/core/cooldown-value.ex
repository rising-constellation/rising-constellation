defmodule Core.CooldownValue do
  use TypedStruct

  def jason(), do: []

  typedstruct enforce: true do
    field(:value, integer() | float())
    field(:initial, integer() | float())
  end

  def new(value \\ 0) do
    %Core.CooldownValue{
      value: value,
      initial: value
    }
  end

  def set(state, value) do
    %{state | value: value, initial: value}
  end

  def next_tick(state, elapsed_time) do
    new_value =
      if elapsed_time > state.value,
        do: 0,
        else: state.value - elapsed_time

    %{state | value: new_value}
  end

  def next_tick_interval(%Core.CooldownValue{value: 0.0}), do: :never
  def next_tick_interval(%Core.CooldownValue{value: 0}), do: :never
  def next_tick_interval(state), do: state.value

  def locked?(state) do
    state.value != 0
  end

  def recently_unlocked?(old, new) do
    locked?(old) and not locked?(new)
  end
end
