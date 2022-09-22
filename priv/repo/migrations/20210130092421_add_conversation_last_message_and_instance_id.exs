defmodule RC.Repo.Migrations.AddConversationLastMessageAndInstanceId do
  use Ecto.Migration

  def change do
    alter table(:conversations) do
      add(:last_message_update, :utc_datetime_usec)
      add(:instance_id, references(:instances, on_delete: :delete_all))
    end
  end
end
