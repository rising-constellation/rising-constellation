defmodule RC.Repo.Migrations.InstancesAddAccountId do
  use Ecto.Migration

  def change do
    alter table(:instances) do
      add(:account_id, references(:accounts, on_delete: :delete_all), default: 1, null: false)
    end

    Ecto.Migration.execute("""
      ALTER TABLE instances ALTER COLUMN "account_id" DROP DEFAULT;
    """)
  end
end
