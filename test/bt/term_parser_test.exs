defmodule BT.TermParserTest do
  use ExUnit.Case
  import Instance.SystemAI.TermParser

  test "parses a tuple with scalars" do
    assert {:ok, {1, 2, 3}} == parse("{1,2,3}")
  end

  test "parses nested structures" do
    assert {:ok, [{:circle, %{cx: 1, cy: 2, r: 3}, nil}]} == parse("[{:circle, %{cx: 1, cy: 2, r: 3}, nil}]")
  end

  test "it returns an error for invalid syntax" do
    assert {:error, _} = parse("{14, ..")
  end

  test "it returns an error for executable code" do
    assert {:error, _} = parse("File.read!(\"/etc/passwd\")")
  end
end
