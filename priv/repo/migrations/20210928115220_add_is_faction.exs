defmodule RC.Repo.Migrations.AddIsFaction do
  use Ecto.Migration

  def change do
    alter table(:conversations) do
      add(:is_faction, :boolean, default: false)
    end

    execute("UPDATE conversations SET is_faction=false;")
  end
end
