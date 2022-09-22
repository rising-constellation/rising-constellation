defmodule RC.Repo.Migrations.CreateStoreTables do
  use Ecto.Migration

  def change do
    create table("store_customers") do
      add(:email, :string, null: false)
      add(:stripe_id, :string, null: false)

      timestamps()
    end

    create(unique_index(:store_customers, [:email]))

    create table("store_inventory") do
      add(:item, :string, null: false)
      add(:type, :string, null: false)
      add(:available_units, :integer, default: 1)
      add(:is_hidden, :boolean, default: false)
    end

    create table("store_purchases") do
      add(:store_customer_id, references(:store_customers), null: false)
      add(:store_inventory_id, references(:store_inventory), null: false)
      add(:payment_result, :map, null: false)

      timestamps()
    end
  end
end
