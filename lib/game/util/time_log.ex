defmodule TimeLog do
  require Logger

  @moduledoc """
  require TimeLog
  result =
    TimeLog.execute "my thing" do
      # something
    end
  """

  defmacro execute(name, do: yield) do
    quote do
      {microseconds, result} = :timer.tc(fn -> unquote(yield) end)
      Logger.info("#{unquote(name)} took #{microseconds}μs")
      result
    end
  end
end
