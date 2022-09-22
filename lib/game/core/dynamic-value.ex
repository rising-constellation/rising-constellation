defmodule Core.DynamicValue do
  use TypedStruct

  def jason(), do: []

  typedstruct enforce: true do
    field(:value, integer() | float())
    field(:change, integer() | float())
    field(:details, %{})
  end

  def new(value) do
    %Core.DynamicValue{
      value: value,
      change: 0,
      details: %{}
    }
  end

  def new(value, type, %Core.ValuePart{} = part) do
    new(value) |> add(type, part)
  end

  def add(%Core.DynamicValue{} = state, type, %Core.ValuePart{} = part) do
    details =
      case Enum.find(state.details, fn {name, _} -> name == type end) do
        nil ->
          Map.put(state.details, type, [part])

        {_, parts} ->
          Map.put(state.details, type, parts ++ [part])
      end

    %{state | change: state.change + part.value, details: details}
  end

  def next_tick(%Core.DynamicValue{} = state, elapsed_time) do
    change_value(state, state.value + elapsed_time * state.change)
  end

  def add_value(%Core.DynamicValue{} = state, amount) do
    change_value(state, state.value + amount)
  end

  def remove_value(%Core.DynamicValue{} = state, amount) do
    add_value(state, -amount)
  end

  def change_value(%Core.DynamicValue{} = state, new_value) do
    %{state | value: new_value}
  end

  def clamp_value(%Core.DynamicValue{} = state, min, max) do
    value =
      cond do
        state.value > max -> max
        state.value < min -> min
        true -> state.value
      end

    %{state | value: value}
  end
end
