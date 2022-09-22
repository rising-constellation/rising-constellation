defmodule RC.Repo.Migrations.CreateScenarios do
  use Ecto.Migration

  def change do
    ScenarioStartSettings.create_type()

    create table(:scenarios) do
      add(:game_data, :map, null: false)
      add(:is_map, :boolean, null: false)
      add(:is_official, :boolean, default: false, null: false)
      add(:thumbnail, :string, null: false)
      add(:start_setting, ScenarioStartSettings.type())

      timestamps(type: :utc_datetime_usec)
    end
  end
end
