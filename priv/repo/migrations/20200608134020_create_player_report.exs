defmodule RC.Repo.Migrations.CreatePlayerReport do
  use Ecto.Migration

  def change do
    create table(:player_report) do
      add(:type, :varchar, null: false)
      add(:is_archived, :boolean, default: false)
      add(:is_starred, :boolean, default: false)
      add(:metadata, :text, null: false)
      add(:report, :text, null: false)
      add(:registration_id, references(:registrations, on_delete: :delete_all), null: false)

      timestamps(updated_at: false)
    end

    create(index(:player_report, [:registration_id]))
  end
end
