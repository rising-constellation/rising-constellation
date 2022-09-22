defmodule Fight.Tile do
  use TypedStruct

  typedstruct enforce: true do
    field(:id, integer())
    field(:ship_status, :empty | :planned | :filled)
    field(:ship, %Fight.Ship{} | nil)
  end

  def convert(tile, character_id, character_level, constant, ships_data) do
    ship =
      if tile.ship_status == :filled,
        do: Fight.Ship.convert(tile.ship, character_id, character_level, tile.id, constant, ships_data),
        else: nil

    %Fight.Tile{
      id: tile.id,
      ship_status: tile.ship_status,
      ship: ship
    }
  end

  def update_ship(state, ship) do
    status =
      if ship == nil,
        do: :empty,
        else: state.ship_status

    %{state | ship_status: status, ship: ship}
  end
end
