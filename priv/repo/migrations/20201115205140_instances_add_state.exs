defmodule RC.Repo.Migrations.InstancesAddState do
  use Ecto.Migration

  def change do
    alter table(:instances) do
      add(:state, :string, default: "created", null: false)
    end

    create(index(:instances, [:state]))
  end
end
