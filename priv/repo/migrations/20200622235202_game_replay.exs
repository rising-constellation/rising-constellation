defmodule RC.Repo.Migrations.GameReplay do
  use Ecto.Migration

  def change do
    create table(:replays) do
      add(:msg, :text, null: false)
      add(:params, :map, null: false)
      add(:channel, :text, null: false)
      add(:instance_id, references(:instances, on_delete: :delete_all), null: false)
      add(:profile_id, references(:profiles, on_delete: :delete_all), null: false)
      add(:timestamp, :utc_datetime_usec, null: false)
    end

    create(index(:replays, [:instance_id]))
    create(index(:replays, [:timestamp]))
  end
end
