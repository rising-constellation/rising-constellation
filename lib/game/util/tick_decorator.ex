defmodule Util.TickDecorator do
  @moduledoc """
  Decorators related to Core.Tick
  """
  use Decorator.Define, tick: 0

  @doc """
  This can be used on GenServer callbacks:
  * handle_call/3
  * handle_cast/2
  * handle_continue/2
  * handle_info/3
  * terminate/2

  It relies on var!/1 to make the macro not hygienic (intentionally mutating and
  leaking 'state')
  see https://elixirschool.com/en/lessons/advanced/metaprogramming/#macro-hygiene
  """
  def tick(body, context) do
    quote do
      var!(state) = next_tick(unquote(List.last(context.args)))
      unquote(body)
    end
  end
end
