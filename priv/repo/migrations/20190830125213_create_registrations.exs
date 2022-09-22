defmodule RC.Repo.Migrations.CreateRegistrations do
  use Ecto.Migration

  def change do
    create table(:registrations) do
      add(:token, :string)
      add(:status, :integer)
      add(:faction_id, references(:factions, on_delete: :delete_all), null: false)
      add(:profil_id, references(:profils, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(index(:registrations, [:faction_id]))
    create(index(:registrations, [:profil_id]))
  end
end
