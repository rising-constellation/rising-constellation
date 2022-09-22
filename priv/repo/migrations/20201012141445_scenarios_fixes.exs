defmodule RC.Repo.Migrations.ScenariosFixes do
  use Ecto.Migration

  def change do
    alter table(:scenarios) do
      modify(:thumbnail, :string, null: true)
      add(:game_metadata, :map)
    end
  end
end
