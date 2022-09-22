defmodule Core.Dice do
  @critical_space 0.05
  @uncertainty_range 0.20

  def roll(instance_id, attacker, attacker_modifier, defender)
      when is_number(attacker) and is_number(attacker_modifier) and is_number(defender) and
             attacker >= 0 and attacker_modifier >= 0 and defender >= 0 do
    ratio = ratio(attacker, defender)
    {min, max} = compute_probability_space(ratio, attacker_modifier)
    value = Game.call(instance_id, :rand, :master, {:uniform, min, max})

    {get_result(value), {ratio, min, max, value}}
  end

  def ratio(attacker, defender) when is_number(attacker) and is_number(defender) and attacker + defender > 0.0,
    do: attacker / (attacker + defender)

  def ratio(_, _),
    do: 0.5

  def ratio_to_factor(ratio),
    do: 2 - abs(ratio - 0.5) * 2

  def reverse_result(:critical_success), do: :critical_failure
  def reverse_result(:normal_success), do: :normal_failure
  def reverse_result(:normal_failure), do: :normal_success
  def reverse_result(:critical_failure), do: :critical_success

  defp compute_probability_space(ratio, modifier) do
    min = ratio - @uncertainty_range + 0.01 * min(modifier, 20)
    max = ratio + @uncertainty_range

    {max(min, 0), min(max, 1)}
  end

  defp get_result(value) when is_number(value), do: result(value)
  defp result(value) when value < @critical_space, do: :critical_failure
  defp result(value) when value < 0.50, do: :normal_failure
  defp result(value) when value < 1 - @critical_space, do: :normal_success
  defp result(_value), do: :critical_success
end
