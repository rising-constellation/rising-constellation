defmodule RC.Repo.Migrations.CreateInstanceGroups do
  use Ecto.Migration

  def change do
    create table(:instance_groups, primary_key: false) do
      add(:instance_id, references(:instances, on_delete: :delete_all), primary_key: true)
      add(:group_id, references(:groups, on_delete: :delete_all), primary_key: true)
    end
  end
end
