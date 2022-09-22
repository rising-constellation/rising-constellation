defmodule RC.Messenger.ConversationMember do
  use Ecto.Schema
  import Ecto.Changeset

  schema "conversation_members" do
    field(:is_admin, :boolean, default: false)
    field(:last_seen, :utc_datetime_usec)
    belongs_to(:conversation, RC.Messenger.Conversation)
    belongs_to(:profile, RC.Accounts.Profile)
    has_many(:messages, RC.Messenger.Message)

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(conversation_member, attrs) do
    conversation_member
    |> cast(attrs, [:is_admin, :last_seen, :conversation_id, :profile_id])
    |> validate_required([:is_admin, :last_seen, :conversation_id])
    |> foreign_key_constraint(:conversation_id)
    |> foreign_key_constraint(:profile_id)
    |> unique_constraint([:conversation_id, :profile_id_id], name: :conv_member_unique)
  end

  @doc false
  def changeset_last_seen(conversation_member, attrs) do
    conversation_member
    |> cast(attrs, [:last_seen])
    |> validate_required([:last_seen])
  end
end
