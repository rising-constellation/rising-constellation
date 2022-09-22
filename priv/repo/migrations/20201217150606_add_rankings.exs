defmodule RC.Repo.Migrations.AddRankings do
  use Ecto.Migration

  def change do
    alter table("profiles") do
      add(:elo, :real, default: 1200)
    end

    create table(:rankings) do
      add(:elo_diff, :real)
      add(:instance_id, references(:instances, on_delete: :delete_all))
      add(:profile_id, references(:profiles, on_delete: :delete_all))

      timestamps(updated_at: false)
    end
  end
end
