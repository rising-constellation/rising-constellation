defmodule Core.VisibilityValue do
  use TypedStruct

  def jason(), do: []

  typedstruct enforce: true do
    field(:value, integer() | float())
    field(:details, %{})
    field(:minimum, [])
  end

  def new() do
    %Core.VisibilityValue{
      value: 0,
      details: %{},
      minimum: []
    }
  end

  def new(type, %Core.ValuePart{} = part) do
    new() |> add(type, part)
  end

  def add(%Core.VisibilityValue{} = state, type, %Core.ValuePart{} = part) do
    details =
      case Enum.find(state.details, fn {name, _} -> name == type end) do
        nil -> Map.put(state.details, type, [part])
        {_, parts} -> Map.put(state.details, type, parts ++ [part])
      end

    %{state | details: details}
    |> compute_value()
    |> force_value()
  end

  def remove(%Core.VisibilityValue{} = state, type) do
    details =
      case Enum.find(state.details, fn {name, _} -> name == type end) do
        nil ->
          state.details

        {_name, parts} ->
          {_part, parts} = List.pop_at(parts, 0)
          Map.put(state.details, type, parts)
      end

    %{state | details: details}
    |> compute_value()
    |> force_value()
  end

  def apply_minimum(%Core.VisibilityValue{} = state, %Core.ValuePart{} = part) do
    %{state | minimum: [part]} |> force_value()
  end

  defp compute_value(%Core.VisibilityValue{} = state) do
    value =
      Enum.reduce(state.details, 0, fn {_, parts}, acc ->
        Enum.reduce(parts, acc, fn part, acc -> acc + part.value end)
      end)

    %{state | value: value}
  end

  defp force_value(%Core.VisibilityValue{} = state) do
    # clamp values between 0 and 5
    value =
      cond do
        state.value > 5 -> 5
        state.value < 0 -> 0
        true -> state.value
      end

    # force value to minimum
    value =
      if not Enum.empty?(state.minimum) and value < hd(state.minimum).value,
        do: hd(state.minimum).value,
        else: value

    %{state | value: value}
  end
end
