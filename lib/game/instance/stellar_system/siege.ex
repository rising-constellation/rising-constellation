defmodule Instance.StellarSystem.Siege do
  use TypedStruct

  alias Instance.StellarSystem

  def jason(), do: []

  typedstruct enforce: true do
    field(:type, atom())
    field(:days, %Core.DynamicValue{})
    field(:duration, integer())
    field(:besieger_id, integer())
  end

  def new(type, duration, besieger_id) do
    days =
      Core.DynamicValue.new(duration)
      |> Core.DynamicValue.add(:misc, Core.ValuePart.new(:default, -1))

    %StellarSystem.Siege{
      type: type,
      days: days,
      duration: duration,
      besieger_id: besieger_id
    }
  end

  def next_tick(state, elapsed_time) do
    state = %{state | days: Core.DynamicValue.next_tick(state.days, elapsed_time)}

    if state.days.value < 0,
      do: {:release_siege, state},
      else: {:keep_siege, state}
  end
end
