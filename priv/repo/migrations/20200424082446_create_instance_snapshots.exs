defmodule RC.Repo.Migrations.CreateInstanceSnapshots do
  use Ecto.Migration

  def change do
    create table(:instance_snapshots) do
      add(:name, :string)
      add(:size, :integer)
      add(:instance_id, references(:instances, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(index(:instance_snapshots, [:instance_id]))
  end
end
