defmodule RC.Store.StoreInventory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "store_inventory" do
    field(:item, :string)
    field(:type, :string)
    field(:available_units, :integer)
    field(:is_hidden, :boolean)
  end

  @doc false
  def changeset(store_inventory, attrs) do
    store_inventory
    |> cast(attrs, [:item, :type, :available_units, :is_hidden])
    |> validate_required([:item, :type, :available_units, :is_hidden])
    |> validate_length(:item, max: 255)
    |> validate_length(:type, max: 120)
  end
end
