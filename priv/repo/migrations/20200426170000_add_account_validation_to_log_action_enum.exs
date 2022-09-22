defmodule RC.Repo.Migrations.AddAccountValidationToLogActionEnum do
  use Ecto.Migration
  @disable_ddl_transaction true

  def up do
    Ecto.Migration.execute("ALTER TYPE log_action ADD VALUE IF NOT EXISTS 'account_validation'")
  end

  def down do
  end
end
