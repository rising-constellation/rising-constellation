defmodule RC.Repo.Migrations.InstanceAddGameMetadata do
  use Ecto.Migration

  def change do
    alter table(:instances) do
      add(:game_metadata, :map)
    end
  end
end
