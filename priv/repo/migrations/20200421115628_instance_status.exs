defmodule RC.Repo.Migrations.InstanceStatus do
  use Ecto.Migration

  def up do
    InstanceRegistrationStatus.create_type()
    InstanceMaintenanceStatus.create_type()
    InstanceGameStatus.create_type()
    InstanceDisplayStatus.create_type()

    alter table("instances") do
      remove(:status)
      remove(:game_status)
      add(:registration_status, InstanceRegistrationStatus.type())
      add(:maintenance_status, InstanceMaintenanceStatus.type())
      add(:game_status, InstanceGameStatus.type())
      add(:display_status, InstanceDisplayStatus.type())
      add(:description, :string)
    end

    GameStatus.drop_type()
    InstanceStatus.drop_type()
  end

  def down do
    GameStatus.create_type()
    InstanceStatus.create_type()

    alter table("instances") do
      add(:status, GameStatus.type())
      add(:game_status, InstanceStatus.type())
      remove(:registration_status)
      remove(:maintenance_status)
      remove(:game_status)
      remove(:display_status)
      remove(:description)
    end

    InstanceRegistrationStatus.drop_type()
    InstanceMaintenanceStatus.drop_type()
    InstanceGameStatus.drop_type()
    InstanceDisplayStatus.drop_type()
  end
end
