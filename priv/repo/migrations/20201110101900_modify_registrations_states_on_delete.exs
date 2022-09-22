defmodule RC.Repo.Migrations.ModifyRegistrationsStatesOnDelete do
  use Ecto.Migration

  def change do
    alter table(:registration_states) do
      modify(:registration_id, references(:registrations, on_delete: :delete_all),
        from: references(:registrations, on_delete: :nothing)
      )
    end
  end
end
