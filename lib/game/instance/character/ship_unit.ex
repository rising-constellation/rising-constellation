defmodule Instance.Character.ShipUnit do
  use TypedStruct

  alias Instance.Character

  def jason(), do: []

  typedstruct enforce: true do
    field(:key, integer())
    field(:hull, float())
  end

  def new(index, data) do
    %Character.ShipUnit{
      key: index,
      hull: data.unit_hull
    }
  end

  def convert(%Fight.ShipUnit{} = unit) do
    hull = if unit.hull == 0, do: 0.001, else: unit.hull

    %Character.ShipUnit{
      key: unit.id,
      hull: hull
    }
  end

  def damage(%Character.ShipUnit{} = state, damage) do
    hull = state.hull - damage
    hull = if hull <= 0, do: 0.001, else: hull

    %{state | hull: hull}
  end

  def repair(%Character.ShipUnit{} = state, hull_points, data) do
    hull = state.hull + hull_points
    hull = if hull >= data.unit_hull, do: data.unit_hull, else: hull

    %{state | hull: hull}
  end
end
