defmodule RC.Repo.Migrations.ChangeAccountNameSize do
  use Ecto.Migration

  def change do
    alter table("accounts") do
      modify(:name, :string, size: 50)
    end
  end
end
