defmodule Instance.StellarSystem.Player do
  use TypedStruct
  use Util.MakeEnumerable

  alias Instance.StellarSystem

  def jason(), do: []

  typedstruct enforce: true do
    field(:id, integer())
    field(:avatar, String.t())
    field(:name, String.t())
    field(:faction, atom())
    field(:faction_id, integer())
  end

  def convert(player) do
    %StellarSystem.Player{
      id: player.id,
      name: player.name,
      avatar: player.avatar,
      faction: player.faction,
      faction_id: player.faction_id
    }
  end
end
