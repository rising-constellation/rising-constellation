defmodule RC.Repo.Migrations.CreateMaintenanceLog do
  use Ecto.Migration

  def change do
    create table(:maintenance_log) do
      add(:flag, :boolean, null: false)
      add(:account_id, references(:accounts, on_delete: :nothing))

      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    create(index(:maintenance_log, [:account_id]))
  end
end
