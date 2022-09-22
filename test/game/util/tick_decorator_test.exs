defmodule Game.Util.TickDecoratorTest do
  use ExUnit.Case, async: true

  describe "Util.TickDecorator @tick decorator" do
    use Util.TickDecorator

    defp next_tick(state) do
      state + 77
    end

    @decorate tick()
    def decorated(_a, state) do
      state
    end

    test "decorates and leaks 'state'" do
      assert decorated(0, 0) == 77
      assert decorated(0, 1) == 78
    end
  end
end
