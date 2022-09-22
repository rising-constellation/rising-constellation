defmodule RC.Repo.Migrations.HidePlayerReports do
  use Ecto.Migration

  def change do
    alter table(:player_report) do
      add(:is_hidden, :boolean, default: false)
    end
  end
end
