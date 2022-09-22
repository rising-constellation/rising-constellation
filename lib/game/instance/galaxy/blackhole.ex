defmodule Instance.Galaxy.Blackhole do
  use TypedStruct
  use Util.MakeEnumerable

  alias Spatial.Position
  alias Instance.Galaxy

  def jason(), do: []

  typedstruct enforce: true do
    field(:id, integer())
    field(:name, String.t())
    field(:position, %Position{})
    field(:radius, integer())
  end

  def new(blackhole) do
    position = %Position{x: blackhole["position"]["x"], y: blackhole["position"]["y"]}

    %Galaxy.Blackhole{
      id: blackhole["key"],
      name: blackhole["name"],
      position: position,
      radius: blackhole["radius"]
    }
  end
end
