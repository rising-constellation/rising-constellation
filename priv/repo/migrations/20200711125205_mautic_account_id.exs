defmodule RC.Repo.Migrations.MauticAccountId do
  use Ecto.Migration

  def change do
    alter table("accounts") do
      add(:mautic_contact_id, :integer)
    end
  end
end
