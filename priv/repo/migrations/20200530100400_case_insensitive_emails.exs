defmodule RC.Repo.Migrations.CaseInsensitiveEmails do
  use Ecto.Migration

  def change do
    create(index(:accounts, ["lower(email)"], unique: true))
  end
end
