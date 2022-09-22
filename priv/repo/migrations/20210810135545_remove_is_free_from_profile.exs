defmodule RC.Repo.Migrations.RemoveIsFreeFromProfile do
  use Ecto.Migration

  def up do
    alter table("profiles") do
      remove(:is_free)
    end
  end
end
