defmodule Instance.Character.Player do
  use TypedStruct
  use Util.MakeEnumerable

  alias Instance.Character

  def jason(), do: []

  typedstruct enforce: true do
    field(:id, integer())
    field(:name, String.t())
    field(:faction, atom())
    field(:faction_id, integer())
  end

  def convert(player) do
    %Character.Player{
      id: player.id,
      name: player.name,
      faction: player.faction,
      faction_id: player.faction_id
    }
  end
end
