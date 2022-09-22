defmodule Core.Value do
  use TypedStruct

  def jason(), do: []

  typedstruct enforce: true do
    field(:value, integer() | float())
    field(:details, %{})
  end

  def new() do
    %Core.Value{
      value: 0,
      details: %{}
    }
  end

  def new(type, %Core.ValuePart{} = part) do
    new() |> add(type, part)
  end

  def add(%Core.Value{} = state, type, %Core.ValuePart{} = part) do
    details =
      case Enum.find(state.details, fn {name, _} -> name == type end) do
        nil ->
          Map.put(state.details, type, [part])

        {_, parts} ->
          Map.put(state.details, type, parts ++ [part])
      end

    %{state | value: state.value + part.value, details: details}
  end

  def clamp_value(%Core.Value{} = state, min, max) do
    value =
      cond do
        state.value > max -> max
        state.value < min -> min
        true -> state.value
      end

    %{state | value: value}
  end
end
