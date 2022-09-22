defmodule Portal.ConversationMemberView do
  use Portal, :view
  alias Portal.ConversationMemberView

  def render("index_member.json", %{conversation_members: members}) do
    render_many(members, ConversationMemberView, "conversation_member.json")
  end

  def render("show_member.json", %{conversation_member: member}) do
    render_one(member, ConversationMemberView, "conversation_member.json")
  end

  def render("conversation_member.json", %{conversation_member: member}) do
    cond do
      Ecto.assoc_loaded?(member.profile) ->
        %{id: member.id, is_admin: member.is_admin, name: member.profile.name, iid: member.profile.id}

      true ->
        %{id: member.id, is_admin: member.is_admin}
    end
  end
end
