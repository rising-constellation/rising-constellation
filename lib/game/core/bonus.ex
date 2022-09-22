defmodule Core.Bonus do
  use TypedStruct

  def jason(), do: []

  typedstruct enforce: true do
    field(:from, %Data.Game.BonusPipelineIn{})
    field(:value, integer() | float())
    field(:type, :add | :mul)
    field(:to, %Data.Game.BonusPipelineOut{})
  end

  def apply_bonus(%{reason: reason, bonus: bonus, to: to, from: from}, data) do
    input = get_input(from, bonus.type, data)
    state = data[to.to]

    previous_value = Map.get(state, to.to_key)

    value =
      cond do
        bonus.type == :mul and previous_value.value < 0 -> 0
        is_number(input) -> input * bonus.value
        true -> 0
      end

    new_value = Util.Type.replace_value(previous_value, value, reason)

    Map.replace!(state, to.to_key, new_value)
  end

  @doc """
  Apply a list of bonuses to `state`.
  The type parameter is an atom such as :stellar_system
  For each item in bonuses, the map item.metadata is turned into a kw list and passed to apply/2 as `data`
  together with the current value of `state` (reduced upon) and the last value of `state` after the last `:add`
  got applied, as `base_state`.
  """
  def apply_bonuses(state, type, bonuses) do
    {state, _} =
      bonuses
      |> prepare()
      |> Enum.reduce({state, state}, fn data, {state, base_state} ->
        kw =
          data.metadata
          |> Map.to_list()
          |> Keyword.put(type, state)
          |> Keyword.put(:base_state, base_state)

        state = apply_bonus(data, kw)

        if data.bonus.type == :mul do
          {state, base_state}
        else
          {state, state}
        end
      end)

    state
  end

  # Return bonuses in the order they should be applied
  defp prepare(bonuses) do
    bonuses
    |> Enum.map(fn %{from: from, bonus: bonus} = data ->
      order =
        cond do
          bonus.from == :direct ->
            # 1. prioritize :direct bonuses, for instance credit_perc is `from X -> to X` but should not be applied
            # before credit_add, which is `from :direct`
            from.order - 2

          bonus.from == bonus.to ->
            # 2. prioritize bonuses that do `from X -> to X` over `from X -> to Y`
            from.order - 1

          true ->
            from.order
        end

      metadata = Map.get(data, :metadata, %{})

      %{data | from: %{from | order: order}}
      |> Map.put(:metadata, metadata)
    end)
    # 3. prioritize :add over :mul
    |> Enum.sort(&(&1.from.order < &2.from.order or (&1.from.order == &2.from.order and &1.bonus.type < &2.bonus.type)))
  end

  defp get_input(%{from: :none} = _from, _type, _data), do: 1

  defp get_input(from, type, data) do
    value =
      case type do
        :add -> data[from.from]
        :mul -> data[:base_state]
      end
      |> Map.get(from.from_key)

    case Util.Type.typeof_value(value) do
      :simple -> value
      :advanced -> value.value
      :dynamic -> value.change
    end
  end
end
