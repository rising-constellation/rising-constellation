defmodule Spatial.Position do
  use TypedStruct
  use Util.MakeEnumerable

  alias Spatial.Disk
  alias Spatial.Position

  def jason(), do: []

  typedstruct enforce: true do
    field(:x, float())
    field(:y, float())
  end

  def distance(%Position{} = pos1, %Position{} = pos2) do
    :math.sqrt(dist_squared(pos1, pos2))
  end

  def dist_squared(%Position{x: x1, y: y1}, %Position{x: x2, y: y2}) do
    :math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2)
  end

  def dist_squared(%Position{x: x1, y: y1}, %Disk{x: x2, y: y2}) do
    :math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2)
  end

  def in_disk(%Position{x: x, y: y}, %Disk{radius: radius} = center) do
    dist_squared(%Position{x: x, y: y}, center) <= :math.pow(radius, 2)
  end

  def substr(%Position{x: x1, y: y1}, %Position{x: x2, y: y2}) do
    %Position{x: x1 - x2, y: y1 - y2}
  end

  def dot(%Position{x: x1, y: y1}, %Position{x: x2, y: y2}) do
    x1 * x2 + y1 * y2
  end
end
