defmodule Fight.ShipUnit do
  use TypedStruct

  typedstruct enforce: true do
    field(:id, integer())
    field(:hull, float())
    field(:status, :alive | :destroyed)
  end

  def convert(unit) do
    %Fight.ShipUnit{id: unit.key, hull: unit.hull, status: :alive} |> update_status()
  end

  def update_status(state) do
    if state.hull == 0,
      do: %{state | status: :destroyed},
      else: state
  end

  def apply_damages(state, damages) do
    # real damages taken can't be greater than hull
    damages = Enum.min([damages, state.hull])
    hull = state.hull - damages

    if hull == 0 do
      {%{state | hull: hull, status: :destroyed}, :hit_and_crashed, damages}
    else
      {%{state | hull: hull}, :hit, damages}
    end
  end
end
