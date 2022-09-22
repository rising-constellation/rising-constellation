defmodule RC.Repo.Migrations.AddIsFree do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add(:is_free, :boolean, default: true)
    end

    execute("UPDATE accounts SET is_free=false;")
  end
end
