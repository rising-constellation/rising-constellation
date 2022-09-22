defmodule RC.Repo.Migrations.RegistrationStateAddState do
  use Ecto.Migration

  def change do
    alter table(:registrations) do
      add(:state, :string, default: "placeholder", null: false)
    end

    Ecto.Migration.execute("""
      ALTER TABLE registrations ALTER COLUMN "state" DROP DEFAULT;
    """)
  end
end
