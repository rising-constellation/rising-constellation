defmodule Instance.Galaxy.StellarSystem do
  use TypedStruct
  use Util.MakeEnumerable

  alias Instance.Galaxy
  alias Spatial.Position

  def jason(), do: []

  typedstruct enforce: true do
    field(:id, integer())
    field(:position, %Position{})
    field(:sector_id, integer())
    field(:type, atom())
    field(:status, atom())
    field(:name, String.t())
    field(:faction, atom() | nil)
    field(:owner, String.t() | nil)
    field(:score, integer())
    field(:class, atom() | nil)
  end

  def convert(system) do
    faction = if system.owner == nil, do: nil, else: system.owner.faction
    owner = if system.owner == nil, do: nil, else: system.owner.name

    %Galaxy.StellarSystem{
      id: system.id,
      position: system.position,
      sector_id: system.sector_id,
      type: system.type,
      status: system.status,
      name: system.name,
      faction: faction,
      owner: owner,
      score: compute_score(system),
      class: system.population_class
    }
  end

  def compute_score(system) do
    length(system.bodies)
  end
end
