defmodule Asylamba.Repo.Migrations.AccountTokenType do
  use Ecto.Migration

  def up do
    TokenType.create_type()

    alter table("account_tokens") do
      add(:type, TokenType.type())
    end
  end

  def down do
    alter table("account_tokens") do
      remove(:type)
    end

    TokenType.drop_type()
  end
end
