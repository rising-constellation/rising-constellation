defmodule BT.ParserTest do
  @moduledoc false

  use ExUnit.Case

  alias BehaviorTree.Node
  alias Instance.SystemAI.Parser

  describe "BT.Parser" do
    test "parse/1" do
      path = "./test/bt/simple.json"
      parsed = Parser.parse!(path, "My tree")

      assert parsed == %Node{
               children: [:foobar],
               repeat_count: 1,
               repeat_total: 1,
               type: :select,
               weights: ''
             }
    end
  end
end
