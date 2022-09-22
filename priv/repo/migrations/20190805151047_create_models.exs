defmodule RC.Repo.Migrations.CreateModels do
  use Ecto.Migration

  def change do
    create table(:models) do
      add(:name, :string)
      add(:game_data, :text)
      add(:description, :text)

      timestamps()
    end
  end
end
