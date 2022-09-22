defmodule Instance.Faction.Player do
  use TypedStruct
  use Util.MakeEnumerable

  alias Instance.Faction

  def jason(), do: []

  typedstruct enforce: true do
    field(:id, integer())
    field(:name, String.t())
  end

  def convert(player) do
    %Faction.Player{
      id: player.id,
      name: player.name
    }
  end
end
