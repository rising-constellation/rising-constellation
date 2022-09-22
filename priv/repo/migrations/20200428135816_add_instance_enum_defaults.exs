defmodule RC.Repo.Migrations.AddInstanceEnumDefaults do
  use Ecto.Migration

  def up do
    Ecto.Migration.execute(
      "UPDATE instances SET registration_status='preregistration' WHERE registration_status IS NULL;"
    )

    Ecto.Migration.execute("UPDATE instances SET maintenance_status='none' WHERE maintenance_status IS NULL;")
    Ecto.Migration.execute("UPDATE instances SET game_status='closed' WHERE game_status IS NULL;")
    Ecto.Migration.execute("UPDATE instances SET display_status='hidden' WHERE display_status IS NULL;")

    alter table(:instances) do
      modify(:registration_status, InstanceRegistrationStatus.type(), default: "preregistration", null: false)
      modify(:maintenance_status, InstanceMaintenanceStatus.type(), default: "none", null: false)
      modify(:game_status, InstanceGameStatus.type(), default: "closed", null: false)
      modify(:display_status, InstanceDisplayStatus.type(), default: "hidden", null: false)
    end
  end

  def down do
    alter table(:instances) do
      modify(:registration_status, InstanceRegistrationStatus.type(), default: nil, null: true)
      modify(:maintenance_status, InstanceMaintenanceStatus.type(), default: nil, null: true)
      modify(:game_status, InstanceGameStatus.type(), default: nil, null: true)
      modify(:display_status, InstanceDisplayStatus.type(), default: nil, null: true)
    end
  end
end
