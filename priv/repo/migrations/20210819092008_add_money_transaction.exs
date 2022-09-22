defmodule RC.Repo.Migrations.AddMoneyTransaction do
  use Ecto.Migration

  def change do
    create table(:money_transactions) do
      add(:amount, :integer)
      add(:money, :integer)
      add(:reason, :text)
      add(:account_id, references(:accounts, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(index(:money_transactions, [:account_id]))
  end
end
