defmodule RC.Repo.Migrations.FixPlayerStatCreditOverflow do
  use Ecto.Migration

  def up do
    alter table(:player_stats) do
      modify(:stored_credit, :bigint)
    end
  end

  def down do
    alter table(:player_stats) do
      modify(:stored_credit, :int)
    end
  end
end
