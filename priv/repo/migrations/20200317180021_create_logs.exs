defmodule Asylamba.Repo.Migrations.CreateLogs do
  use Ecto.Migration

  def change do
    create table(:logs) do
      add(:action, :integer)
      add(:account_id, references(:accounts, on_delete: :nothing))

      timestamps()
    end

    create(index(:logs, [:account_id]))
  end
end
