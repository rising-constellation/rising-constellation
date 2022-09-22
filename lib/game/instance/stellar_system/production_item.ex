defmodule Instance.StellarSystem.ProductionItem do
  use TypedStruct

  alias Instance.StellarSystem

  def jason(), do: []

  typedstruct enforce: true do
    field(:id, integer())
    field(:type, :building | :building_repairs | :ship)
    field(:target_id, String.t())
    field(:tile_id, integer())
    field(:prod_key, atom())
    field(:prod_level, integer())
    field(:total_prod, float())
    field(:remaining_prod, float())
  end

  def new(type, production_data, id) do
    {target_id, tile_id, prod_key, prod_level, prod_cost} = production_data

    %StellarSystem.ProductionItem{
      id: id,
      type: type,
      target_id: target_id,
      tile_id: tile_id,
      prod_key: prod_key,
      prod_level: prod_level,
      total_prod: prod_cost,
      remaining_prod: prod_cost
    }
  end

  def add_production(state, production) do
    if state.remaining_prod >= production do
      {:unfinished, %{state | remaining_prod: state.remaining_prod - production}}
    else
      {:finished, production - state.remaining_prod}
    end
  end
end
