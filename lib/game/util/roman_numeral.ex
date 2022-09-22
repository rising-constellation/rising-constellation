defmodule Util.RomanNumerals do
  @moduledoc """
  Converts a positive integer as its parameter to a string containing
  the Roman Numeral representation of that integer.
  """

  def convert(number) do
    convert(number, [[10, 'X'], [9, 'IX'], [5, 'V'], [4, 'IV'], [1, 'I']])
  end

  defp convert(0, _) do
    ''
  end

  defp convert(number, [[arabic, roman] | _] = l) when number >= arabic do
    roman ++ convert(number - arabic, l)
  end

  defp convert(number, [_ | t]) do
    convert(number, t)
  end
end
