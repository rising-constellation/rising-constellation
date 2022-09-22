defmodule RC.Repo.Migrations.CreateUploads do
  use Ecto.Migration

  def change do
    create table(:uploads) do
      add(:name, :string, null: false)
      add(:file, :string, null: false)
      add(:medium_file, :string)
      add(:thumb_file, :string)
      add(:content_type, :string, null: false)
      add(:account_id, references(:accounts, on_delete: :delete_all), null: false)

      timestamps(type: :utc_datetime_usec)
    end
  end
end
