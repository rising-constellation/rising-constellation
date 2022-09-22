defmodule RC.Messenger do
  @moduledoc """
  The Messenger context.
  """

  import Ecto.Query, warn: false
  alias RC.Repo

  alias RC.Messenger.Message
  alias RC.Messenger.ConversationMember
  alias RC.Messenger.Conversation
  alias RC.Accounts.Profile

  alias Ecto.Multi

  @doc """
  Run a transaction to create a private conversation between account or profiles.

  ## Examples

      iex> run_create_private_conversation_transaction(aid1, aid2, pid1, pid2)
      {:ok, inserted_structs}

      iex> crun_create_private_conversation_transaction(bad_aid1, bad_aid2, pid1, pid2)
      {:error, failed_operation, failed_value, changes_so_far}

  """
  def run_create_private_conversation_transaction(
        sender_pid,
        receiver_pid,
        instance_id \\ nil
      ) do
    creation_time = DateTime.utc_now()

    trx =
      Multi.new()
      |> Multi.insert(
        :conversation,
        Conversation.changeset(
          %Conversation{},
          %{
            name: "None",
            is_group: false,
            last_message_update: DateTime.utc_now(),
            instance_id: instance_id
          }
        )
      )
      |> Multi.insert(
        :sender_conv_member,
        fn %{conversation: conversation} ->
          member_params = %{
            is_admin: false,
            last_seen: creation_time,
            conversation_id: conversation.id,
            profile_id: sender_pid
          }

          ConversationMember.changeset(%ConversationMember{}, member_params)
        end
      )
      |> Multi.insert(
        :receiver_conv_member,
        fn %{conversation: conversation} ->
          member_params = %{
            is_admin: false,
            last_seen: DateTime.from_unix!(0),
            conversation_id: conversation.id,
            profile_id: receiver_pid
          }

          ConversationMember.changeset(%ConversationMember{}, member_params)
        end
      )

    Repo.transaction(trx)
  end

  @doc """
  Run a transaction to create a group conversation between account or profiles.
  """
  def run_create_group_conversation_transaction(
        name,
        content_raw,
        admin_pid,
        profiles_ids,
        instance_id \\ nil,
        is_faction \\ false
      ) do
    conversation_params = %{
      name: name,
      is_group: true,
      last_message_update: DateTime.utc_now(),
      instance_id: instance_id,
      is_faction: is_faction
    }

    creation_time = DateTime.utc_now()

    # conversation and admin
    trx =
      Multi.new()
      |> Multi.insert(:conversation, Conversation.changeset(%Conversation{}, conversation_params))
      |> Multi.insert(:admin_member, fn %{conversation: conversation} ->
        # admin
        admin_member_params = %{
          is_admin: true,
          last_seen: creation_time,
          conversation_id: conversation.id,
          profile_id: admin_pid
        }

        ConversationMember.changeset(%ConversationMember{}, admin_member_params)
      end)

    # users participants
    {trx, _cnt} =
      Enum.reduce(profiles_ids, {trx, 0}, fn profile_id, {trx_acc, cnt_acc} ->
        {trx_acc
         |> Multi.insert("member_#{cnt_acc}", fn %{conversation: conversation} ->
           member_params = %{
             is_admin: false,
             last_seen: DateTime.from_unix!(0),
             conversation_id: conversation.id,
             profile_id: profile_id
           }

           ConversationMember.changeset(%ConversationMember{}, member_params)
         end), cnt_acc + 1}
      end)

    # first message
    trx =
      trx
      |> Multi.insert(:message, fn %{conversation: conversation, admin_member: admin_member} ->
        message_params = %{
          content_raw: content_raw,
          conversation_member_id: admin_member.id,
          conversation_id: conversation.id
        }

        Message.changeset(%Message{}, message_params)
      end)

    Repo.transaction(trx)
  end

  @doc """
  Lists all messages of a conversation with the number of unread messages.
  """
  def list_messages(params, conversation_id) do
    from(m in Message,
      join: cm in ConversationMember,
      on: m.conversation_member_id == cm.id
    )
    |> where([m, cm, msg_sender], m.conversation_id == ^conversation_id)
    |> order_by([m, cm, msg_sender], desc: m.inserted_at)
    |> select([m, cm, msg_sender], %{
      id: m.id,
      content_html: m.content_html,
      name: msg_sender.name,
      pid: msg_sender.id,
      inserted_at: m.inserted_at
    })
    |> join(:inner, [m, cm], msg_sender in Profile, on: cm.profile_id == msg_sender.id)
    |> Repo.paginate(params)
  end

  @doc """
  Creates a message.

  ## Examples

      iex> create_message_transation(%{field: value}, conversation)
      {:ok, %{message: %Message{}, conversation: %Conversation{}}

      iex> create_message_transaction(%{field: bad_value}, conversation)
       {:error, failed_operation, failed_value, changes_so_far}

  """
  def create_message_transaction(attrs, conversation) do
    trx =
      Multi.new()
      |> Multi.insert(:message, Message.changeset(%Message{}, attrs))
      |> Multi.update(:conversation, fn %{message: message} ->
        Conversation.changeset(conversation, %{last_message_update: message.inserted_at})
      end)
      |> Multi.update(:conversation_member, fn %{message: message} ->
        %ConversationMember{id: message.conversation_member_id}
        |> ConversationMember.changeset_last_seen(%{last_seen: message.inserted_at})
      end)

    Repo.transaction(trx)
  end

  @doc """
  Lists all conversation not related to any instance.
  """
  def list_conversations(params, profile_id) do
    from(c in Conversation,
      as: :conversation,
      inner_join: cm in assoc(c, :conversation_members),
      inner_join: p in assoc(cm, :profile),
      inner_join: m in Message,
      on: m.conversation_id == c.id,
      preload: [conversation_members: [:profile]],
      order_by: [desc: c.last_message_update],
      group_by: [c.id],
      where: is_nil(c.instance_id) and p.id == ^profile_id and cm.profile_id == ^profile_id,
      select_merge: %{unread: fragment("sum((? < ?)::int)", cm.last_seen, m.inserted_at)}
    )
    |> Repo.paginate(params)
  end

  @doc """
  Lists all private conversation existing for a profile in a given instance.
  """
  def list_conversations(params, iid, profile_id) do
    from(c in Conversation,
      as: :conversation,
      inner_join: cm in assoc(c, :conversation_members),
      inner_join: p in assoc(cm, :profile),
      inner_join: m in Message,
      on: m.conversation_id == c.id,
      preload: [conversation_members: [:profile]],
      order_by: [desc: c.last_message_update],
      group_by: [c.id],
      where: c.instance_id == ^iid and p.id == ^profile_id and cm.profile_id == ^profile_id,
      select_merge: %{unread: fragment("sum((? < ?)::int)", cm.last_seen, m.inserted_at)}
    )
    |> Repo.paginate(params)
  end

  @doc """
  Lists all group faction conversation existing for a given instance.
  """
  def list_conversations_by_faction(iid, faction_id) do
    from(c in Conversation,
      inner_join: cm in assoc(c, :conversation_members),
      inner_join: p in assoc(cm, :profile),
      inner_join: r in assoc(p, :registrations),
      inner_join: f in assoc(r, :faction),
      group_by: [c.id],
      where: f.instance_id == ^iid and c.instance_id == ^iid and c.is_faction == true and r.faction_id == ^faction_id
    )
    |> Repo.all()
  end

  @doc """
  Gets a single conversation with details
  """
  def get_conversation_details(conversation_id, profile_id) do
    from(c in Conversation,
      as: :conversation,
      inner_join: cm in assoc(c, :conversation_members),
      inner_join: p in assoc(cm, :profile),
      inner_join: m in Message,
      on: m.conversation_id == c.id,
      preload: [conversation_members: [:profile]],
      order_by: [desc: c.last_message_update],
      group_by: [c.id],
      where: c.id == ^conversation_id and p.id == ^profile_id and cm.profile_id == ^profile_id,
      select_merge: %{unread: fragment("sum((? < ?)::int)", cm.last_seen, m.inserted_at)}
    )
    |> Repo.one()
  end

  @doc """
  Gets a single conversation.

  ## Examples

      iex> get_conversation!(123)
      %Conversation{}

      iex> get_conversation(456)
      nil

  """
  def get_conversation(id) do
    Repo.get(Conversation, id)
    |> Repo.preload(conversation_members: [:profile])
  end

  @doc """
  Gets a private conversation.
  """

  def get_private_conversation(pid_sender, pid_receiver, instance_id) do
    from(c in Conversation,
      join: cm_sender in ConversationMember,
      on: cm_sender.conversation_id == c.id,
      join: cm_receiver in ConversationMember,
      on: cm_receiver.conversation_id == c.id,
      where:
        cm_sender.conversation_id == c.id and cm_receiver.conversation_id == c.id and c.is_group == false and
          cm_sender.profile_id == ^pid_sender and cm_receiver.profile_id == ^pid_receiver and
          c.instance_id == ^instance_id
    )
    |> Repo.one()
  end

  @doc """
  Check if a conversation exists with the given id.

  """
  def conversation_exists?(id) do
    Repo.exists?(
      from(c in Conversation,
        where: c.id == ^id
      )
    )
  end

  @doc """
  Check if the account is admin for a given conversation and account.
  """
  def conversation_admin?(cid, aid, profile_id) do
    Repo.exists?(
      from(cm in ConversationMember,
        join: profile in Profile,
        on: profile.id == cm.profile_id,
        where:
          cm.conversation_id == ^cid and profile.account_id == ^aid and profile.id == ^profile_id and
            cm.is_admin == true
      )
    )
  end

  @doc """
  Check if the account is admin for a given conversation and account.
  """
  def conversation_member?(cid, account_id, profile_id) do
    Repo.exists?(
      from(cm in ConversationMember,
        join: profile in Profile,
        on: profile.id == cm.profile_id,
        where: cm.conversation_id == ^cid and profile.account_id == ^account_id and profile.id == ^profile_id
      )
    )
  end

  @doc """
  Creates a conversation_member.

  ## Examples

      iex> create_conversation_member(%{field: value})
      {:ok, %ConversationMember{}}

      iex> create_conversation_member(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_conversation_member(attrs \\ %{}) do
    %ConversationMember{}
    |> ConversationMember.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a `ConversationMember`.

  ## Examples

      iex> delete_conversation_member(1, 1)
      {:ok, %ConversationMember{}}

      iex> create_conversation_member(1, 6)
      {:error, :conversation_member_not_found}
  """
  def delete_conversation_member(cid, pid) do
    case get_conversation_member(cid, pid) do
      nil -> {:error, :conversation_member_not_found}
      conversation_member -> Repo.delete(conversation_member)
    end
  end

  @doc """
  Updates a conversation_member.

  ## Examples

      iex> update_conversation_member(conversation_member, %{field: new_value})
      {:ok, %ConversationMember{}}

      iex> update_conversation_member(conversation_member, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_conversation_member(%ConversationMember{} = conversation_member, attrs) do
    conversation_member
    |> ConversationMember.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Gets a single conversation_member.
  """
  def get_conversation_member(conversation_id, profile_id) do
    from(cm in ConversationMember,
      where: cm.conversation_id == ^conversation_id and cm.profile_id == ^profile_id
    )
    |> Repo.one()
  end

  @doc """
  List all conversation members in a conversation
  """
  def list_conversation_members(conversation_id) do
    from(cm in ConversationMember,
      left_join: c in Conversation,
      on: c.id == cm.conversation_id,
      where: cm.conversation_id == ^conversation_id
    )
    |> preload(:profile)
    |> Repo.all()
  end
end
