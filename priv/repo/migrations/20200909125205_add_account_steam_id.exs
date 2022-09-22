defmodule RC.Repo.Migrations.SteamAccounts do
  use Ecto.Migration

  def change do
    alter table("accounts") do
      add(:steam_id, :numeric, null: true)
    end

    create(unique_index(:accounts, [:steam_id]))
    drop(unique_index(:accounts, [:name]))
  end
end
