defmodule RC.Repo.Migrations.RemoveScenarioStartSetting do
  use Ecto.Migration

  def change do
    alter table(:scenarios) do
      remove(:start_setting)
    end
  end
end
