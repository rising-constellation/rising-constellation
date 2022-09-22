defmodule RC.Repo.Migrations.CreateOffer do
  use Ecto.Migration

  def change do
    create table(:offers) do
      add(:type, :string, null: false)
      add(:status, :string, null: false)
      add(:data, :text, null: false)
      add(:internal, :binary, null: true)
      add(:value, :integer, null: false)
      add(:price, :integer, null: false)
      add(:is_public, :boolean, null: false)
      add(:profile_id, references(:profiles, on_delete: :delete_all), null: false)
      add(:instance_id, references(:instances, on_delete: :delete_all), null: false)

      timestamps()
    end

    create table(:offers_profiles, primary_key: false) do
      add(:offer_id, references(:offers))
      add(:profile_id, references(:profiles))
    end

    create table(:offers_factions, primary_key: false) do
      add(:offer_id, references(:offers))
      add(:faction_id, references(:factions))
    end

    create(index(:offers, [:instance_id]))
    create(index(:offers, [:profile_id]))
    create(index(:offers_profiles, [:offer_id]))
    create(index(:offers_profiles, [:profile_id]))
    create(index(:offers_factions, [:offer_id]))
    create(index(:offers_factions, [:faction_id]))
  end
end
