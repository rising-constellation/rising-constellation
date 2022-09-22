defmodule Core.ValuePart do
  use TypedStruct

  def jason(), do: []

  typedstruct enforce: true do
    field(:reason, String.t() | atom())
    field(:value, integer() | float())
  end

  def new(reason, value) do
    %Core.ValuePart{
      reason: reason,
      value: value
    }
  end
end
