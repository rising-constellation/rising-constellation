defmodule RC.Repo.Migrations.FkMissingIndexes do
  use Ecto.Migration

  def change do
    create(index(:registration_states, [:registration_id]))
    create(index(:instance_states, [:instance_id]))
    create(index(:instance_states, [:account_id]))
  end
end
