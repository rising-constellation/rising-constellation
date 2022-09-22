defmodule Asylamba.Repo.Migrations.CreateAccountTokens do
  use Ecto.Migration

  def change do
    create table(:account_tokens) do
      add(:value, :string)
      add(:account_id, references(:accounts, on_delete: :nothing))

      timestamps()
    end

    create(index(:account_tokens, [:account_id]))
  end
end
