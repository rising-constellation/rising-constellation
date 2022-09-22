defmodule Portal.MessageView do
  use Portal, :view
  alias Portal.MessageView

  def render("index_with_members.json", %{messages: messages, conversation_members: members}) do
    messages_view = render_many(messages, MessageView, "message.json")
    members_view = render_many(members, Portal.ConversationMemberView, "conversation_member.json")

    %{messages: messages_view, conversation_members: members_view}
  end

  def render("index.json", %{messages: messages}) do
    render_many(messages, MessageView, "message.json")
  end

  def render("show.json", %{message: message}) do
    render_one(message, MessageView, "message.json")
  end

  def render("message.json", %{message: message}) do
    %{
      id: message.id,
      content_html: message.content_html,
      name: message.name,
      pid: message.pid,
      date: message.inserted_at
    }
  end
end
