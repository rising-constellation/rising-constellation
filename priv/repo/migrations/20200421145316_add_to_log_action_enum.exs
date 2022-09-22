defmodule RC.Repo.Migrations.AddToLogActionEnum do
  use Ecto.Migration
  @disable_ddl_transaction true

  def up do
    Ecto.Migration.execute("ALTER TYPE log_action ADD VALUE IF NOT EXISTS 'reset_password'")
  end

  def down do
  end
end
