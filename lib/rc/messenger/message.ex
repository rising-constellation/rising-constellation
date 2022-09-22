defmodule RC.Messenger.Message do
  use Ecto.Schema
  import Ecto.Changeset
  alias RC.Markdown

  schema "messages" do
    field(:content_raw, :string)
    field(:content_html, :string)
    belongs_to(:conversation_member, RC.Messenger.ConversationMember)
    belongs_to(:conversation, RC.Messenger.Conversation)

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content_raw, :conversation_member_id, :conversation_id])
    |> validate_required([:content_raw, :conversation_member_id, :conversation_id])
    |> validate_length(:content_raw, max: 50_000)
    |> foreign_key_constraint(:conversation_id)
    |> foreign_key_constraint(:conversation_member_id)
    |> Markdown.render_changeset(:content_raw, :content_html)
  end
end
