defmodule RC.Repo.Migrations.AccountSettingsServerSettings do
  use Ecto.Migration

  def change do
    alter table("accounts") do
      add(:lang, :string, size: 2, default: nil)
      add(:settings, :jsonb, default: "{}")
    end

    alter table("maintenance_log") do
      add(:min_client_version, :string, size: 10, default: "0.0.0")
    end
  end
end
