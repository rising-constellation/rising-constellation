defmodule RC.Repo.Migrations.CreateFactions do
  use Ecto.Migration

  def change do
    create table(:factions) do
      add(:faction_ref, :string)
      add(:capacity, :integer)
      add(:instance_id, references(:instances, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(index(:factions, [:instance_id]))
  end
end
