defmodule RC.Repo.Migrations.UpdateProfiles do
  use Ecto.Migration

  def change do
    alter table(:profiles) do
      add(:full_name, :string)
      add(:description, :string)
      add(:long_description, :string)
      add(:age, :integer)
    end
  end
end
