defmodule RC.Messenger.Conversation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "conversations" do
    field(:name, :string)
    field(:is_group, :boolean)
    field(:is_faction, :boolean, default: false)
    field(:last_message_update, :utc_datetime_usec)
    has_many(:messages, RC.Messenger.Message)
    has_many(:conversation_members, RC.Messenger.ConversationMember)
    belongs_to(:instance, RC.Instances.Instance)

    field(:unread, :integer, virtual: true)

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:name, :is_group, :last_message_update, :instance_id, :is_faction])
    |> validate_required([:name, :is_group, :last_message_update])
    |> validate_length(:name, max: 120)
  end
end
