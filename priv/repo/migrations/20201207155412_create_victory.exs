defmodule RC.Repo.Migrations.CreateVictory do
  use Ecto.Migration

  def change do
    create table(:victories) do
      add(:victory_type, :string)
      add(:instance_id, references(:instances, on_delete: :delete_all))

      timestamps(updated_at: false)
    end

    create(unique_index(:victories, [:instance_id]))

    alter table(:factions) do
      add(:final_rank, :integer, default: nil)
    end
  end
end
