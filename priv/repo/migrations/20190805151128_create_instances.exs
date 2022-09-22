defmodule RC.Repo.Migrations.CreateInstances do
  use Ecto.Migration

  def change do
    create table(:instances) do
      add(:name, :string)
      add(:metadata, :text)
      add(:game_data, :text)
      add(:opening_date, :utc_datetime)
      add(:status, :integer)
      add(:game_status, :integer)

      timestamps()
    end
  end
end
