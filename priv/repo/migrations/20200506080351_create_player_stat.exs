defmodule RC.Repo.Migrations.CreatePlayerStat do
  use Ecto.Migration

  def change do
    create table(:player_stats) do
      add(:output_credit, :integer, null: false)
      add(:output_technology, :integer, null: false)
      add(:output_ideology, :integer, null: false)
      add(:stored_credit, :integer, null: false)
      add(:total_systems, :integer, null: false)
      add(:total_population, :integer, null: false)
      add(:points, :integer, null: false)
      add(:best_prod, :integer, null: false)
      add(:best_credit, :integer, null: false)
      add(:best_technology, :integer, null: false)
      add(:best_ideology, :integer, null: false)
      add(:best_workforce, :integer, null: false)
      add(:instance_id, references(:instances, on_delete: :delete_all), null: false)
      add(:registration_id, references(:registrations, on_delete: :delete_all), null: false)

      timestamps()
    end
  end
end
