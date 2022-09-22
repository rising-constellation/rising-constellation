defmodule RC.Repo.Migrations.AddMoneyToAccount do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add(:money, :integer, default: 0)
    end

    alter table(:accounts) do
      modify(:money, :integer, default: nil, null: false)
    end
  end
end
