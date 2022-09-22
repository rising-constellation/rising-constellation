defmodule RC.Repo.Migrations.ReplayResult do
  use Ecto.Migration

  def change do
    alter table(:replays) do
      add(:result, :text)
    end
  end
end
