defmodule RC.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add(:email, :string)
      add(:hashed_password, :string)
      add(:name, :string)
      add(:role, :integer)
      add(:status, :integer)

      timestamps()
    end

    create(unique_index(:accounts, [:email]))
    create(unique_index(:accounts, [:name]))
  end
end
