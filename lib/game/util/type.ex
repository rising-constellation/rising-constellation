defmodule Util.Type do
  def advanced_value?(%Core.Value{} = _value), do: true
  def advanced_value?(_value), do: false

  def advanced_dynamic_value?(%Core.DynamicValue{} = _value), do: true
  def advanced_dynamic_value?(_value), do: false

  def typeof_value(value) when is_map(value) do
    if advanced_value?(value),
      do: :advanced,
      else: :dynamic
  end

  def typeof_value(_), do: :simple

  def replace_value(current_value, value, reason) do
    {type, key} = reason

    case typeof_value(current_value) do
      :simple -> value
      :advanced -> Core.Value.add(current_value, type, Core.ValuePart.new(key, value))
      :dynamic -> Core.DynamicValue.add(current_value, type, Core.ValuePart.new(key, value))
    end
  end
end
