defmodule RC.Repo.Migrations.InstanceStatesAccountIdNotNullable do
  use Ecto.Migration

  def change do
    execute("UPDATE instance_states as u SET account_id = i2.account_id FROM instance_states AS i2
      WHERE u.id = i2.id - 1 AND u.instance_id = i2.instance_id AND u.account_id IS NULL;")

    alter table(:instance_states) do
      modify(:account_id, references(:accounts, on_delete: :nothing),
        null: false,
        from: references(:accounts, on_delete: :nothing)
      )
    end
  end
end
