defmodule Instance.Victory.Sector do
  use TypedStruct
  use Util.MakeEnumerable

  alias Instance.Victory

  def jason(), do: []

  typedstruct enforce: true do
    field(:id, integer())
    field(:name, String.t())
    field(:value, integer())
    field(:owner, atom())
  end

  def convert(sector) do
    %Victory.Sector{
      id: sector.id,
      name: sector.name,
      value: sector.victory_points,
      owner: sector.owner
    }
  end
end
