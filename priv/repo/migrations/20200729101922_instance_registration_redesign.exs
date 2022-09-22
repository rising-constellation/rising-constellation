defmodule RC.Repo.Migrations.InstanceRegistrationRedesign do
  use Ecto.Migration

  def change do
    InstanceGameType.create_type()
    InstanceRegistrationType.create_type()
    # ScenarioStartSettings.create_type()

    alter table("profiles") do
      add(:is_free, :boolean, default: true)
    end

    alter table("registrations") do
      remove(:status)
      # add :state, :string, default: "joined"
    end

    # modify instances
    # rename table("instances"), :registration_status, to: :old_registration_status

    alter table("instances") do
      remove(:maintenance_status)
      remove(:game_status)
      remove(:display_status)
      remove(:metadata)
      add(:registration_type, InstanceRegistrationType.type())
      add(:game_type, InstanceGameType.type())
      add(:start_setting, ScenarioStartSettings.type())
      add(:public, :boolean)
    end

    # String to Jsonb up & down
    execute(
      "alter table instances alter column game_data type jsonb using (game_data::jsonb)",
      "alter table instances alter column game_data type string"
    )

    create table("instance_states") do
      add(:state, :string, null: false)
      add(:instance_id, references(:instances, on_delete: :nothing), null: false)
      add(:account_id, references(:accounts, on_delete: :nothing))

      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    create table("registration_states") do
      add(:state, :string, null: false)
      add(:registration_id, references(:registrations, on_delete: :nothing), null: false)

      timestamps(type: :utc_datetime_usec, updated_at: false)
    end
  end
end
