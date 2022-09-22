defmodule RC.Repo.Migrations.CreateAccountGroups do
  use Ecto.Migration

  def change do
    create table(:account_groups, primary_key: false) do
      add(:account_id, references(:accounts, on_delete: :delete_all), primary_key: true)
      add(:group_id, references(:groups, on_delete: :delete_all), primary_key: true)
    end
  end
end
