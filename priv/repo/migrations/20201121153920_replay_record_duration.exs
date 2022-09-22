defmodule RC.Repo.Migrations.ReplayRecordDuration do
  use Ecto.Migration

  def change do
    alter table(:replays) do
      add(:duration, :integer, default: -1, null: false)
    end
  end
end
