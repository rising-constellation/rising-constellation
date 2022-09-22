defmodule RC.Store.StorePurchase do
  use Ecto.Schema
  import Ecto.Changeset

  schema "store_purchases" do
    belongs_to(:store_customer, RC.Store.StoreCustomer)
    belongs_to(:store_inventory, RC.Store.StoreInventory)
    field(:payment_result, :map)

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(store_purchase, attrs) do
    store_purchase
    |> cast(attrs, [:store_customer_id, :store_inventory_id, :payment_result])
    |> validate_required([:store_customer_id, :store_inventory_id, :payment_result])
    |> foreign_key_constraint(:store_customer_id)
    |> foreign_key_constraint(:store_inventory_id)
  end
end
