defmodule Instance.Player.StellarSystem do
  use TypedStruct
  use Util.MakeEnumerable

  alias Instance.Player
  alias Spatial.Position

  def jason(), do: []

  typedstruct enforce: true do
    field(:id, integer())
    field(:position, %Position{})
    field(:sector_id, integer())
    field(:name, String.t())
    field(:type, atom())
    field(:status, atom())
    field(:governor, integer() | nil)
    field(:characters, [integer()] | [])
    field(:queue, integer())
    field(:workforce, integer())
    field(:habitation, integer())
    field(:production, float())
    field(:technology, float())
    field(:ideology, float())
    field(:credit, float())
    field(:happiness, float())
    field(:defense, float())
    field(:radar, float())
    field(:siege, atom() | nil)
  end

  def convert(system) do
    %Player.StellarSystem{
      id: system.id,
      position: system.position,
      sector_id: system.sector_id,
      name: system.name,
      type: system.type,
      status: system.status,
      governor: system.governor,
      characters: system.characters,
      queue: Queue.length(system.queue.queue),
      workforce: system.workforce,
      habitation: system.habitation.value,
      production: system.production.value,
      technology: system.technology.value,
      ideology: system.ideology.value,
      credit: system.credit.value,
      happiness: system.happiness.value,
      defense: system.defense.value,
      radar: system.radar.value,
      siege: system.siege
    }
  end
end
