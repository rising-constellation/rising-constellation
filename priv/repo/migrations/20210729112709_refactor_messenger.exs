defmodule Elixir.RC.Repo.Migrations.RefactorMessenger do
  use Ecto.Migration

  def up do
    alter table("conversations") do
      remove(:is_between_profiles)
    end

    drop(unique_index("conversation_members", [:conversation_id, :account_id, :profile_id], name: :conv_member_unique))

    alter table("conversation_members") do
      remove(:account_id)
    end

    execute("DROP TRIGGER _check_profiles_on_conversations ON conversation_members;")
    execute("DROP FUNCTION check_profiles_on_conversations;")

    create(unique_index("conversation_members", [:conversation_id, :profile_id], name: :conv_member_unique))
  end
end
