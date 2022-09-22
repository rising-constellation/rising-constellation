defmodule RC.Repo.Migrations.CreateFolders do
  use Ecto.Migration

  def change do
    create table(:folders) do
      add(:name, :string)
      add(:description, :string)
      add(:account_id, references(:accounts, on_delete: :nothing))

      timestamps(type: :utc_datetime_usec)
    end

    create(index(:folders, [:account_id]))
    create(index(:folders, [:name]))

    create table(:scenarios_folders, primary_key: false) do
      add(:folder_id, references(:folders, on_delete: :delete_all), primary_key: true)
      add(:scenario_id, references(:scenarios, on_delete: :delete_all), primary_key: true)
    end

    create(index(:scenarios_folders, [:scenario_id]))
  end
end
