defmodule Notification.System do
  use TypedStruct
  use Util.MakeEnumerable

  def jason(), do: []

  typedstruct enforce: true do
    field(:id, integer())
    field(:position, %Spatial.Position{})
    field(:sector_id, integer())
    field(:name, String.t())
    field(:type, atom())
    field(:status, atom())
    field(:owner, %Instance.StellarSystem.Player{} | nil)
    # field(:population, float())
    # field(:population_status, atom())
    # field(:habitation, float())
    # field(:production, float())
    # field(:technology, float())
    # field(:ideology, float())
    # field(:credit, float())
    # field(:happiness, float())
    # field(:mobility, float())
    # field(:counter_intelligence, float())
    # field(:defense, float())
    # field(:remove_contact, float())
    # field(:radar, float())
  end

  def convert(system) do
    %Notification.System{
      id: system.id,
      position: system.position,
      sector_id: system.sector_id,
      name: system.name,
      type: system.type,
      status: system.status,
      owner: system.owner
    }
  end
end
