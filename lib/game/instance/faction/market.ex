defmodule Instance.Faction.Market do
  use TypedStruct
  use Util.MakeEnumerable

  alias Core.DynamicValue
  alias Instance.Faction
  alias Faction.Faction

  @moduledoc false

  @change -0.4
  @minimum_value 5

  def jason(), do: []

  typedstruct enforce: true do
    field(:credit, %DynamicValue{})
    field(:technology, %DynamicValue{})
    field(:ideology, %DynamicValue{})
  end

  def new do
    %Instance.Faction.Market{
      credit: %DynamicValue{value: @minimum_value, details: [], change: @change},
      technology: %DynamicValue{value: @minimum_value, details: [], change: @change},
      ideology: %DynamicValue{value: @minimum_value, details: [], change: @change}
    }
  end

  # Action handling

  def send_resources(faction_state, {from_player_id, to_player_id, resources}) do
    credit_to_send = resources |> Map.get("credit", 0) |> Kernel.max(0)
    technology_to_send = resources |> Map.get("technology", 0) |> Kernel.max(0)
    ideology_to_send = resources |> Map.get("ideology", 0) |> Kernel.max(0)

    # tax included amounts to send
    sending = %{
      credit: apply_tax(faction_state.data, :credit, credit_to_send),
      technology: apply_tax(faction_state.data, :technology, technology_to_send),
      ideology: apply_tax(faction_state.data, :ideology, ideology_to_send)
    }

    with {:ok, sender} <- Game.call(faction_state.instance_id, :player, from_player_id, :get_state),
         # we can only send positive amounts, and only amounts we actually possess, and not to ourself
         true <- can_send(sender, sending, :credit),
         true <- can_send(sender, sending, :technology),
         true <- can_send(sender, sending, :ideology),
         true <- from_player_id != to_player_id or :cannot_send_to_yourself,
         :ok <-
           Game.call(
             faction_state.instance_id,
             :player,
             from_player_id,
             {:add_resources, -sending.credit, -sending.technology, -sending.ideology}
           ),
         true <-
           Game.call(
             faction_state.instance_id,
             :player,
             to_player_id,
             {:add_resources, credit_to_send, technology_to_send, ideology_to_send}
           ) == :ok or :refund do
      data =
        faction_state.data
        |> tax_and_increase(:credit, credit_to_send)
        |> tax_and_increase(:technology, technology_to_send)
        |> tax_and_increase(:ideology, ideology_to_send)

      {:reply, :ok, %{faction_state | data: data}}
    else
      :refund ->
        Game.call(
          faction_state.instance_id,
          :player,
          from_player_id,
          {:add_resources, sending.credit, sending.technology, sending.ideology}
        )

        {:reply, {:error, :market_receiver_unavailable}, faction_state}

      reason when is_atom(reason) ->
        {:reply, {:error, reason}, faction_state}

      _error ->
        {:reply, :error, faction_state}
    end
  end

  def lower_market_taxes({change, state}, elapsed_time) do
    market_taxes =
      Enum.reduce(state.market_taxes, %{}, fn {key, tax}, acc ->
        tax = DynamicValue.next_tick(tax, elapsed_time)

        lowered_tax =
          if tax.value < 5 do
            # lowest tax is 5%
            5
          else
            Float.round(tax.value, 2)
          end

        Map.put(acc, key, DynamicValue.change_value(tax, lowered_tax))
      end)

    {MapSet.put(change, :market_taxes_update), %{state | market_taxes: market_taxes}}
  end

  # Private functions

  defp apply_tax(%Faction{} = _state, _type, 0), do: 0

  defp apply_tax(%Faction{market_taxes: market_taxes} = _state, type, amount) do
    tax = Map.fetch!(market_taxes, type).value
    amount + amount * (tax / 100)
  end

  defp increase_tax(%DynamicValue{} = tax, amount, factor) do
    # We could implement different taxes per faction.
    # Max tax is 100%
    new_tax = Kernel.min(60, tax.value + amount / factor)
    DynamicValue.change_value(tax, new_tax)
  end

  defp tax_and_increase(state, _type, 0), do: state

  defp tax_and_increase(%Faction{market_taxes: market_taxes} = state, type, amount) do
    market_taxes =
      case type do
        :credit ->
          Map.update!(market_taxes, :credit, &increase_tax(&1, amount, 2500))

        :technology ->
          Map.update!(market_taxes, :technology, &increase_tax(&1, amount, 200))

        :ideology ->
          Map.update!(market_taxes, :ideology, &increase_tax(&1, amount, 200))
      end

    %{state | market_taxes: market_taxes}
  end

  defp can_send(sender, sending, type) do
    amount_possessed = Map.get(sender, type).value
    # cost_to_send = amount to send + tax
    cost_to_send = Map.get(sending, type)

    cond do
      cost_to_send == 0 -> true
      cost_to_send > 0 and cost_to_send <= amount_possessed -> true
      cost_to_send > amount_possessed -> String.to_atom("not_enough_#{type}")
    end
  end
end
