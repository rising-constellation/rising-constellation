defmodule Portal.MessengerController do
  @moduledoc """
  The Messenger controller.

  API:

  * `:pid` is always the current user's profile ID
  * `:cid` is a conversation ID
  * `:profile_to_{add,remove}` are profile IDs

  ### Create

  Create a new conversation:
      `POST    /messenger/new/:pid`
      `{"to": receiver_profile_id, "content_raw": "some markdown"}`

  Create a new conversation scoped to an instance:
      `POST    /messenger/new/:pid/:iid`
      `{"to": receiver_profile_id, "content_raw": "some markdown"}`

  Create a new group conversation:
      `POST    /messenger/new/:pid/group`
      `{"profiles_ids": receiver_profile_ids[], "content_raw": "some markdown"}`

  Create a new group conversation scoped to an instance:
      `POST    /messenger/new/:pid/:iid/group`
      `{"profiles_ids": receiver_profile_ids[], "content_raw": "some markdown"}`

  ### Send

  Send a message to a conversation:
      `POST    /messenger/:pid/:cid`
      `{"content_raw": "some markdown"}`

  ### List

  List all non-instance conversations:
      `GET     /messenger/:pid`

  List conversations scoped to an instance:
      `GET     /messenger/:pid/instance/:iid`

  Show messages in a conversation:
      `GET     /messenger/:pid/:cid`

  ### Group

  Add a profile to an existing conversation:
      `PUT     /messenger/:pid/:cid/add/:profile_to_add`

  Remove a profile from an existing conversation:
      `DELETE  /messenger/:pid/:cid/remove/:profile_to_remove`

  """
  use Portal, :controller

  alias RC.Messenger
  alias RC.Messenger.Conversation
  alias Portal.Controllers.{PortalChannel, PlayerChannel}

  require Logger

  action_fallback(Portal.FallbackController)

  def index_messages(conn, %{"cid" => cid, "pid" => profile_id} = params) do
    with conversation when not is_nil(conversation) <- Messenger.get_conversation(cid),
         messages = Messenger.list_messages(params, cid),
         {:ok, _} <- update_last_seen(cid, messages, profile_id) do
      conn
      |> Scrivener.Headers.paginate(messages)
      |> put_view(Portal.MessageView)
      |> render("index.json", messages: messages)
    else
      error -> error
    end
  end

  def index(conn, %{"pid" => pid} = params) do
    conversations = Messenger.list_conversations(params, pid)

    conn
    |> Scrivener.Headers.paginate(conversations)
    |> put_view(Portal.ConversationView)
    |> render("index.json", conversations: conversations)
  end

  def index_by_instance(conn, %{"iid" => iid, "pid" => pid} = params) do
    conversations = Messenger.list_conversations(params, iid, pid)

    conn
    |> Scrivener.Headers.paginate(conversations)
    |> put_view(Portal.ConversationView)
    |> render("index.json", conversations: conversations)
  end

  def send_or_create_conv(conn, %{"iid" => _iid, "pid" => _pid} = params), do: _send_or_create_conv(conn, params)
  def send_or_create_conv(conn, params), do: _send_or_create_conv(conn, Map.put(params, "iid", nil))

  def _send_or_create_conv(conn, %{
        "iid" => instance_id,
        "pid" => pid_sender,
        "to" => pid_receiver,
        "content_raw" => content_raw
      }) do
    with account_receiver when not is_nil(account_receiver) <- RC.Accounts.get_account_by_profile(pid_receiver),
         {:ok, status, conversation, sender_conversation_member} <-
           get_or_create_conversation(pid_sender, pid_receiver, instance_id),
         {:ok, %{message: message, conversation: conversation}} <-
           Messenger.create_message_transaction(
             %{
               content_raw: content_raw,
               conversation_member_id: sender_conversation_member.id,
               conversation_id: conversation.id
             },
             conversation
           ) do
      if status == :created do
        broadcast_new_conv(pid_sender, conversation)
        broadcast_new_conv(pid_receiver, conversation)
      else
        broadcast_message(pid_sender, conversation, message)
        broadcast_message(pid_receiver, conversation, message)
      end

      conn
      |> put_status(:created)
      |> json(%{message: :message_sent_to_profile, cid: conversation.id, content_html: message.content_html})
    else
      nil ->
        conn
        |> put_status(404)
        |> json(%{message: :receiver_not_found})

      error ->
        error
    end
  end

  def send_to_conv(
        conn,
        %{
          "pid" => pid_sender,
          "cid" => conversation_id,
          "content_raw" => content_raw
        }
      ) do
    with conversation_member <- Messenger.get_conversation_member(conversation_id, pid_sender),
         conversation <- Messenger.get_conversation(conversation_id),
         true <- (not is_nil(conversation_member) and not is_nil(conversation)) or :conversation_not_found,
         {:ok, %{message: message, conversation: conversation}} <-
           Messenger.create_message_transaction(
             %{
               content_raw: content_raw,
               conversation_member_id: conversation_member.id,
               conversation_id: conversation_member.conversation_id
             },
             conversation
           ) do
      Enum.each(conversation.conversation_members, fn member ->
        broadcast_message(member.profile_id, conversation, message)
      end)

      conn
      |> put_status(:created)
      |> json(%{
        message: :message_sent,
        cid: conversation.id,
        content_html: message.content_html
      })
    else
      :conversation_not_found ->
        conn
        |> put_status(:not_found)
        |> json(%{message: :conversation_not_found})

      error ->
        error
    end
  end

  def add_profile(conn, %{"pid" => _pid, "cid" => cid, "profile_to_add" => profile_to_add}) do
    with conversation <- Messenger.get_conversation(cid),
         true <- not is_nil(conversation) or :conversation_not_found,
         true <- conversation.is_group or :not_a_group_conversation,
         conv_member_attrs = %{
           conversation_id: conversation.id,
           profile_id: profile_to_add,
           last_seen: DateTime.utc_now(),
           is_admin: false
         },
         {:ok, _conversation_member} <- Messenger.create_conversation_member(conv_member_attrs),
         conversation <- Messenger.get_conversation(cid) do
      conn
      |> put_status(200)
      |> json(%{
        message: :profile_added_to_conversation,
        conversation: Portal.ConversationView.render("conversation.json", %{conversation: conversation})
      })
    else
      :account_not_found ->
        conn
        |> put_status(:not_found)
        |> json(%{message: :account_not_found})

      :conversation_not_found ->
        conn
        |> put_status(:not_found)
        |> json(%{message: :conversation_not_found})

      :not_a_group_conversation ->
        conn
        |> put_status(403)
        |> json(%{message: :not_a_group_conversation})

      _error ->
        conn
        |> put_status(403)
        |> json(%{message: :error})
    end
  end

  def remove_profile(conn, %{"pid" => _pid, "cid" => cid, "profile_to_remove" => profile_to_remove}) do
    with conversation <- Messenger.get_conversation(cid),
         true <- not is_nil(conversation) or :conversation_not_found,
         true <- conversation.is_group or :not_a_group_conversation,
         {:ok, _member} <- Messenger.delete_conversation_member(cid, profile_to_remove),
         conversation <- Messenger.get_conversation(cid) do
      conn
      |> put_status(200)
      |> json(%{
        message: :profile_removed_to_conversation,
        conversation: Portal.ConversationView.render("conversation.json", %{conversation: conversation})
      })
    else
      _error ->
        conn
        |> put_status(403)
        |> json(%{message: :error})
    end
  end

  def create_conv_group(
        conn,
        %{"pid" => admin_pid, "profiles_ids" => profiles_ids, "content_raw" => content_raw, "name" => name} = params
      ) do
    conversation_tx =
      if Map.has_key?(params, "iid") do
        {profiles_ids, is_faction} =
          if Map.has_key?(params, "faction") do
            profiles_ids =
              params["iid"]
              |> RC.Registrations.list_by_faction(params["faction"])
              |> Enum.map(fn registration -> registration.profile.id end)
              |> Enum.filter(fn id -> id != String.to_integer(admin_pid) end)

            {profiles_ids, true}
          else
            {profiles_ids, false}
          end

        Messenger.run_create_group_conversation_transaction(
          name,
          content_raw,
          admin_pid,
          profiles_ids,
          params["iid"],
          is_faction
        )
      else
        Messenger.run_create_group_conversation_transaction(name, content_raw, admin_pid, profiles_ids)
      end

    case conversation_tx do
      {:ok, %{conversation: conversation}} ->
        broadcast_new_conv(admin_pid, conversation)

        Enum.each(profiles_ids, fn pid ->
          broadcast_new_conv(pid, conversation)
        end)

        conn
        |> put_status(:created)
        |> json(%{message: :message_sent, cid: conversation.id})

      {:error, :invalid_profiles_ids} ->
        conn
        |> put_status(400)
        |> json(%{message: :invalid_profiles_ids})

      error ->
        error
    end
  end

  defp broadcast_new_conv(profile_id, %Conversation{instance_id: nil, id: id}) do
    conversation = Messenger.get_conversation_details(id, profile_id)

    PortalChannel.broadcast_change("portal:profile:#{profile_id}", %{
      new_conversation: Portal.ConversationView.render("conversation.json", %{conversation: conversation})
    })
  end

  defp broadcast_new_conv(profile_id, %Conversation{instance_id: _instance_id, id: id}) do
    conversation = Messenger.get_conversation_details(id, profile_id)

    PlayerChannel.broadcast_change("instance:player:#{conversation.instance_id}:#{profile_id}", %{
      new_conversation: Portal.ConversationView.render("conversation.json", %{conversation: conversation})
    })
  end

  defp broadcast_message(profile_id, %Conversation{instance_id: nil} = conversation, message) do
    PortalChannel.broadcast_change("portal:profile:#{profile_id}", %{
      new_message: %{
        conversation: Portal.ConversationView.render("conversation.json", %{conversation: conversation}),
        message: %{
          cid: conversation.id,
          id: message.id,
          cm_id: message.conversation_member_id,
          content_html: message.content_html,
          inserted_at: message.inserted_at
        }
      }
    })
  end

  defp broadcast_message(profile_id, %Conversation{instance_id: _instance_id} = conversation, message) do
    PlayerChannel.broadcast_change("instance:player:#{conversation.instance_id}:#{profile_id}", %{
      new_message: %{
        conversation: Portal.ConversationView.render("conversation.json", %{conversation: conversation}),
        message: %{
          cid: conversation.id,
          id: message.id,
          cm_id: message.conversation_member_id,
          content_html: message.content_html,
          inserted_at: message.inserted_at
        }
      }
    })
  end

  def update_last_seen(conversation_id, pid) do
    conversation_member = Messenger.get_conversation_member(conversation_id, pid)

    {:ok, last_seen} = DateTime.now("Etc/UTC")
    modif_attrs = %{last_seen: last_seen}

    unless is_nil(conversation_member) do
      Messenger.update_conversation_member(conversation_member, modif_attrs)
    end

    {:ok, last_seen}
  end

  defp update_last_seen(conversation_id, messages, pid) do
    case Messenger.get_conversation_member(conversation_id, pid) do
      nil ->
        {:error, :conversation_member_not_found}

      conversation_member ->
        most_recent_message = Enum.max_by(messages, fn msg -> msg.id end).inserted_at
        {:ok, most_recent_message} = DateTime.from_naive(most_recent_message, "Etc/UTC")

        if DateTime.compare(most_recent_message, conversation_member.last_seen) == :gt do
          modif_attrs = %{last_seen: most_recent_message}
          Messenger.update_conversation_member(conversation_member, modif_attrs)
        else
          {:ok, nil}
        end
    end
  end

  defp create_conversation_and_members(pid_sender, pid_receiver, instance_id) do
    case Messenger.run_create_private_conversation_transaction(pid_sender, pid_receiver, instance_id) do
      {:ok, %{conversation: conversation, sender_conv_member: sender_conversation_member}} ->
        {:ok, :created, conversation, sender_conversation_member}

      error ->
        error
    end
  end

  defp get_or_create_conversation(pid_sender, pid_receiver, instance_id) do
    case Messenger.get_private_conversation(pid_sender, pid_receiver, instance_id) do
      nil ->
        create_conversation_and_members(pid_sender, pid_receiver, instance_id)

      conversation ->
        case Messenger.get_conversation_member(conversation.id, pid_sender) do
          # should not match bc conversation exists
          nil ->
            {:error, :conversation_member_not_found}

          conversation_member ->
            {:ok, :existing, conversation, conversation_member}
        end
    end
  end

  # defp message_empty?({:content_raw, {_, [validation: :required]}}), do: true
  # defp message_empty?(_), do: false
  # defp message_too_long?({:content_raw, {_, [count: _, validation: :length, kind: :max, type: _]}}), do: true
  # defp message_too_long?(_), do: false

  # defp message_error(conn, errors) do
  #   IO.inspect(errors, label: "ERROR MESSAGES")

  #   cond do
  #     # Enum.any?(errors, &message_empty?/1) ->
  #     #   conn |> put_status(422) |> json(%{message: :message_empty})

  #     # Enum.any?(errors, &message_too_long?/1) ->
  #     #   conn |> put_status(422) |> json(%{message: :message_too_long})

  #     true ->
  #       {:error, errors}
  #   end
  # end
end
