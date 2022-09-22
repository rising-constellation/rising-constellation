defmodule RC.Store.StoreCustomer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "store_customers" do
    field(:email, :string)
    field(:stripe_id, :string)

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(store_customer, attrs) do
    store_customer
    |> cast(attrs, [:email, :stripe_id])
    |> validate_required([:email, :stripe_id])
    |> unique_constraint(:email)
    |> validate_length(:email, max: 120)
  end
end
