defmodule RC.Repo.Migrations.CreatePlayerEvent do
  use Ecto.Migration

  def change do
    create table(:player_events) do
      add(:key, :string, null: false)
      add(:type, :string, null: false)
      add(:data, :text, null: true)
      add(:instance_id, references(:instances, on_delete: :delete_all), null: false)
      add(:registration_id, references(:registrations, on_delete: :delete_all), null: true)
      add(:faction_id, references(:factions, on_delete: :delete_all), null: true)

      timestamps(updated_at: false)
    end

    create(index(:player_events, [:instance_id]))
    create(index(:player_events, [:registration_id]))
    create(index(:player_events, [:faction_id]))
  end
end
