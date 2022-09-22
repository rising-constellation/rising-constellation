defmodule RC.Repo.Migrations.CreateProfils do
  use Ecto.Migration

  def change do
    create table(:profils) do
      add(:name, :string)
      add(:avatar, :string)
      add(:account_id, references(:accounts, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(unique_index(:profils, [:name]))
    create(index(:profils, [:account_id]))
  end
end
