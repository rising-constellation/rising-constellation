defmodule RC.Repo.Migrations.AddNewEmailToAccountTokens do
  use Ecto.Migration
  @disable_ddl_transaction true

  def up do
    Ecto.Migration.execute("ALTER TYPE token_type ADD VALUE IF NOT EXISTS 'email_update'")
    Ecto.Migration.execute("ALTER TYPE log_action ADD VALUE IF NOT EXISTS 'update_with_email'")

    alter table("account_tokens") do
      add(:candidate_email, :string)
    end
  end

  def down do
    alter table("account_tokens") do
      remove(:candidate_email)
    end
  end
end
