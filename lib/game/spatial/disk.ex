defmodule Spatial.Disk do
  use TypedStruct
  use Util.MakeEnumerable

  def jason(), do: []

  typedstruct enforce: true do
    field(:x, float())
    field(:y, float())
    field(:radius, float())
  end
end
