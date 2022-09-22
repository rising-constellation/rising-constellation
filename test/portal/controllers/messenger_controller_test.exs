defmodule Portal.MessengerControllerTest do
  use Portal.APIConnCase, async: true

  alias RC.Messenger
  alias RC.Messenger.Message
  alias RC.Messenger.Conversation
  alias RC.Accounts
  alias RC.Repo
  alias RC.Markdown
  import Ecto.Query
  import RC.ScenarioFixtures

  @stored_file_path "#{File.cwd!()}/#{Application.compile_env(:waffle, :storage_dir)}/"

  @message_attrs %{
    content_raw: "some message"
  }

  @message_empty_attrs %{
    content_raw: ""
  }

  @create_attrs_user %{
    email: "user1@user1",
    password: "some password",
    name: "some name",
    role: :user,
    status: :registered
  }

  @create_attrs_user2 %{
    email: "user2@user2",
    password: "some other password",
    name: "some other name",
    role: :user,
    status: :registered
  }

  @create_attrs_user3 %{
    email: "user3@user3",
    password: "some another password",
    name: "some another name",
    role: :user,
    status: :registered
  }

  @create_attrs_profile1 %{
    name: "some name",
    avatar: "TODO"
  }

  @create_attrs_profile2 %{
    name: "some other name",
    avatar: "TODO"
  }

  @create_attrs_profile3 %{
    name: "some another name",
    avatar: "TODO"
  }

  setup %{conn: conn} do
    on_exit(fn -> File.rm_rf(@stored_file_path) end)
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  def fixture(:user1) do
    {:ok, account} = Accounts.create_account(@create_attrs_user)
    account
  end

  def fixture(:user2) do
    {:ok, account2} = Accounts.create_account(@create_attrs_user2)
    account2
  end

  def fixture(:user3) do
    {:ok, account3} = Accounts.create_account(@create_attrs_user3)
    account3
  end

  def login(conn, account) do
    {:ok, jwt, _full_claims} = RC.Guardian.encode_and_sign(account, %{})

    conn =
      conn
      |> put_req_header("authorization", "Bearer #{jwt}")
      |> put_req_header("content-type", "text/plain")

    conn
  end

  defp create_two_accounts(_) do
    account1 = fixture(:user1)
    account2 = fixture(:user2)
    {:ok, profile1} = Accounts.create_profile(@create_attrs_profile1 |> Map.put(:account_id, account1.id))
    {:ok, profile2} = Accounts.create_profile(@create_attrs_profile2 |> Map.put(:account_id, account2.id))
    {:ok, accounts: %{account1: account1, account2: account2, profile1: profile1, profile2: profile2}}
  end

  defp create_three_accounts(_) do
    account1 = fixture(:user1)
    account2 = fixture(:user2)
    account3 = fixture(:user3)
    {:ok, profile1} = Accounts.create_profile(@create_attrs_profile1 |> Map.put(:account_id, account1.id))
    {:ok, profile2} = Accounts.create_profile(@create_attrs_profile2 |> Map.put(:account_id, account2.id))
    {:ok, profile3} = Accounts.create_profile(@create_attrs_profile3 |> Map.put(:account_id, account3.id))

    {:ok,
     accounts: %{
       account1: account1,
       account2: account2,
       account3: account3,
       profile1: profile1,
       profile2: profile2,
       profile3: profile3
     }}
  end

  defp create_instance(_) do
    %{instance: instance} = instance_fixture()
    {:ok, instance: instance}
  end

  defp build_api_conn() do
    build_conn() |> put_req_header("accept", "application/json")
  end

  describe "send_or_create_conv" do
    setup [:create_two_accounts, :create_instance]

    test "returns error if message empty", %{
      conn: conn,
      accounts: %{account1: account1, profile1: profile1, profile2: profile2},
      instance: instance
    } do
      conn =
        conn
        |> login(account1)
        |> post(Routes.messenger_path(conn, :send_or_create_conv, profile1.id, instance.id),
          to: profile2.id,
          content_raw: @message_empty_attrs.content_raw
        )

      assert json_response(conn, 400)["message"]["content_raw"] == ["can't be blank"]
    end

    test "sends a message to a receiver", %{
      conn: conn,
      accounts: %{account1: account1, profile1: profile1, profile2: profile2},
      instance: instance
    } do
      conn =
        conn
        |> login(account1)
        |> post(Routes.messenger_path(conn, :send_or_create_conv, profile1.id, instance.id),
          to: profile2.id,
          content_raw: @message_attrs.content_raw
        )

      resp = json_response(conn, 201)

      [message | _] = RC.Repo.all(Message)

      assert "message_sent_to_profile" == resp["message"]
      assert message.content_raw == @message_attrs.content_raw
      assert resp["content_html"] == Markdown.render_inline(@message_attrs.content_raw)

      assert message.conversation_member_id ==
               Messenger.get_conversation_member(resp["cid"], profile1.id).id
    end

    test "sends a message twice to a receiver", %{
      conn: conn,
      accounts: %{account1: account1, profile1: profile1, profile2: profile2},
      instance: instance
    } do
      conn =
        conn
        |> login(account1)
        |> post(Routes.messenger_path(conn, :send_or_create_conv, profile1.id, instance.id),
          to: profile2.id,
          content_raw: @message_attrs.content_raw
        )

      assert json_response(conn, 201)

      conn =
        build_conn()
        |> login(account1)
        |> post(Routes.messenger_path(conn, :send_or_create_conv, profile1.id, instance.id),
          to: profile2.id,
          content_raw: @message_attrs.content_raw
        )

      assert resp2 = json_response(conn, 201)

      conn =
        build_api_conn()
        |> login(account1)
        |> get(Routes.messenger_path(conn, :index_messages, profile1.id, resp2["cid"]))

      assert resp = json_response(conn, 200)
      assert resp |> length() == 2
    end

    test "returns error if invalid receiver id", %{
      conn: conn,
      accounts: %{account1: account1, profile1: profile1, profile2: profile2},
      instance: instance
    } do
      conn =
        conn
        |> login(account1)
        |> post(Routes.messenger_path(conn, :send_or_create_conv, profile1.id, instance.id),
          to: profile2.id * 2,
          content_raw: @message_attrs.content_raw
        )

      assert json_response(conn, 404)["message"] == "receiver_not_found"
      assert [] = RC.Repo.all(RC.Messenger.ConversationMember)
    end

    test "returns error if message is empty", %{
      conn: conn,
      accounts: %{account1: account1, profile1: profile1, profile2: profile2},
      instance: instance
    } do
      conn =
        conn
        |> login(account1)
        |> post(Routes.messenger_path(conn, :send_or_create_conv, profile1.id, instance.id),
          to: profile2.id,
          content_raw: ""
        )

      assert json_response(conn, 400)["message"]["content_raw"] == ["can't be blank"]
    end
  end

  describe "create group between profiles" do
    setup [:create_three_accounts, :create_instance]

    test "create a profile group conversation", %{
      conn: conn,
      accounts: %{
        account1: account1,
        profile1: profile1,
        profile2: profile2,
        profile3: profile3
      }
    } do
      conn =
        conn
        |> login(account1)
        |> post(Routes.messenger_path(conn, :create_conv_group, profile1.id),
          profiles_ids: [profile2.id, profile3.id],
          content_raw: @message_attrs.content_raw,
          name: "TODO"
        )

      response = json_response(conn, 201)

      conversation = RC.Repo.get!(RC.Messenger.Conversation, response["cid"])

      assert Repo.aggregate(RC.Messenger.ConversationMember, :count, :id) == 3
      assert response["message"] == "message_sent"
      assert conversation.is_group == true
    end

    test "return error if profile id does not exist", %{
      conn: conn,
      accounts: %{
        account1: account1,
        profile1: profile1,
        profile2: profile2,
        profile3: profile3
      }
    } do
      conn =
        conn
        |> login(account1)
        |> post(Routes.messenger_path(conn, :create_conv_group, profile1.id),
          profiles_ids: [profile2.id * 2, profile3.id],
          content_raw: @message_attrs.content_raw,
          name: "TODO"
        )

      assert response = json_response(conn, 400)
      assert Repo.aggregate(RC.Messenger.ConversationMember, :count, :id) == 0
      assert Repo.aggregate(RC.Messenger.Conversation, :count, :id) == 0
      assert response["message"] == %{"profile_id" => ["does not exist"]}
    end
  end

  describe "conversation group scoped to an instance" do
    setup [:create_three_accounts, :create_instance]

    test "create a profile group conversation", %{
      conn: conn,
      accounts: %{
        account1: account1,
        profile1: profile1,
        profile2: profile2,
        profile3: profile3
      },
      instance: instance
    } do
      conn =
        conn
        |> login(account1)
        |> post(Routes.messenger_path(conn, :create_conv_group, profile1.id, instance.id),
          profiles_ids: [profile2.id, profile3.id],
          content_raw: @message_attrs.content_raw,
          name: "TODO"
        )

      response = json_response(conn, 201)

      conversation = RC.Repo.get!(RC.Messenger.Conversation, response["cid"])

      assert Repo.aggregate(RC.Messenger.ConversationMember, :count, :id) == 3
      assert response["message"] == "message_sent"
      assert conversation.is_group == true
    end

    test "return error if profile id does not exist", %{
      conn: conn,
      accounts: %{
        account1: account1,
        profile1: profile1,
        profile2: profile2,
        profile3: profile3
      },
      instance: instance
    } do
      conn =
        conn
        |> login(account1)
        |> post(Routes.messenger_path(conn, :create_conv_group, profile1.id, instance.id),
          profiles_ids: [profile2.id * 2, profile3.id],
          content_raw: @message_attrs.content_raw,
          name: "TODO"
        )

      assert response = json_response(conn, 400)
      assert Repo.aggregate(RC.Messenger.ConversationMember, :count, :id) == 0
      assert Repo.aggregate(RC.Messenger.Conversation, :count, :id) == 0
      assert response["message"] == %{"profile_id" => ["does not exist"]}
    end
  end

  describe "index" do
    setup [:create_three_accounts]

    test "lists the right conversations", %{
      conn: conn,
      accounts: %{
        account1: account1,
        account2: account2,
        account3: account3,
        profile1: profile1,
        profile2: profile2,
        profile3: profile3
      }
    } do
      conn =
        conn
        |> login(account1)
        |> post(Routes.messenger_path(conn, :send_or_create_conv, profile1.id),
          to: profile3.id,
          content_raw: @message_attrs.content_raw
        )

      json_response(conn, 201)

      conn =
        build_api_conn()
        |> login(account2)
        |> post(Routes.messenger_path(conn, :send_or_create_conv, profile2.id),
          to: profile3.id,
          content_raw: @message_attrs.content_raw
        )

      json_response(conn, 201)

      conn =
        build_api_conn()
        |> login(account3)
        |> post(Routes.messenger_path(conn, :send_or_create_conv, profile3.id),
          to: profile1.id,
          content_raw: @message_attrs.content_raw
        )
        |> get(Routes.messenger_path(conn, :index, profile3.id))

      conv_account3 = json_response(conn, 200)

      conn =
        build_api_conn()
        |> login(account3)
        |> get(Routes.messenger_path(conn, :index, profile2.id))

      json_response(conn, 403)

      conn =
        build_api_conn()
        |> login(account1)
        |> get(Routes.messenger_path(conn, :index, profile1.id))

      conv_account1 = json_response(conn, 200)

      assert length(conv_account3) == 3
      assert length(conv_account1) == 2
    end
  end

  describe "unread" do
    setup [:create_two_accounts]

    test "returns the number of unread messages for one conversation", %{
      conn: conn,
      accounts: %{account1: account1, account2: account2, profile1: profile1, profile2: profile2}
    } do
      conn =
        conn
        |> login(account1)
        |> post(Routes.messenger_path(conn, :send_or_create_conv, profile1.id),
          to: profile2.id,
          content_raw: @message_attrs.content_raw
        )
        |> post(Routes.messenger_path(conn, :send_or_create_conv, profile1.id),
          to: profile2.id,
          content_raw: @message_attrs.content_raw
        )
        |> post(Routes.messenger_path(conn, :send_or_create_conv, profile1.id),
          to: profile2.id,
          content_raw: @message_attrs.content_raw
        )

      conn =
        build_api_conn()
        |> login(account2)
        |> get(Routes.messenger_path(conn, :index, profile2.id))

      assert [conv_account1 | _] = json_response(conn, 200)

      assert conv_account1["unread"] == 1
    end

    test "returns 0 if messages were read", %{
      conn: conn,
      accounts: %{account1: account1, account2: account2, profile1: profile1, profile2: profile2}
    } do
      conn =
        conn
        |> login(account1)
        |> post(Routes.messenger_path(conn, :send_or_create_conv, profile1.id),
          to: profile2.id,
          content_raw: @message_attrs.content_raw
        )
        |> post(Routes.messenger_path(conn, :send_or_create_conv, profile1.id),
          to: profile2.id,
          content_raw: @message_attrs.content_raw
        )
        |> post(Routes.messenger_path(conn, :send_or_create_conv, profile1.id),
          to: profile2.id,
          content_raw: @message_attrs.content_raw
        )

      %{"cid" => conversation_id} = json_response(conn, 201)

      Process.sleep(1_000)

      conn =
        build_api_conn()
        |> login(account2)
        |> get(Routes.messenger_path(conn, :index_messages, profile2.id, conversation_id))

      assert json_response(conn, 200)
      Process.sleep(1_000)

      conn =
        build_api_conn()
        |> login(account2)
        |> get(Routes.messenger_path(conn, :index, profile2.id))

      assert [conv_account2 | _] = json_response(conn, 200)

      assert conv_account2["unread"] == 0
    end
  end

  describe "index messages" do
    setup [:create_three_accounts]

    test "returns the message of one conversation", %{
      conn: conn,
      accounts: %{account1: account1, profile1: profile1, profile2: profile2}
    } do
      conn =
        conn
        |> login(account1)
        |> post(Routes.messenger_path(conn, :send_or_create_conv, profile1.id),
          to: profile2.id,
          content_raw: @message_attrs.content_raw
        )

      %{"cid" => conversation_id} = json_response(conn, 201)

      conn =
        build_api_conn()
        |> login(account1)
        |> get(Routes.messenger_path(conn, :index_messages, profile1.id, conversation_id))

      assert resp = json_response(conn, 200)

      [messages_head | messages_tail] = resp
      [message_page | _] = conn.assigns.messages.entries

      assert messages_head["content_html"] == Markdown.render_inline(@message_attrs.content_raw)
      assert messages_tail == []
      assert conn.assigns.messages.total_entries == 1
      assert message_page.content_html == Markdown.render_inline(@message_attrs.content_raw)
    end

    test "returns 403 for messages of someone else's conversation", %{
      conn: conn,
      accounts: %{account1: account1, account3: account3, profile1: profile1, profile2: profile2}
    } do
      conn =
        conn
        |> login(account1)
        |> post(Routes.messenger_path(conn, :send_or_create_conv, profile1.id),
          to: profile2.id,
          content_raw: @message_attrs.content_raw
        )

      %{"cid" => conversation_id} = json_response(conn, 201)

      conn =
        build_api_conn()
        |> login(account3)
        |> get(Routes.messenger_path(conn, :index_messages, profile1.id, conversation_id))

      assert json_response(conn, 403)
    end

    test "updates last seen value", %{
      conn: conn,
      accounts: %{account1: account1, account2: account2, profile1: profile1, profile2: profile2}
    } do
      conn =
        conn
        |> login(account1)
        |> post(Routes.messenger_path(conn, :send_or_create_conv, profile1.id),
          to: profile2.id,
          content_raw: @message_attrs.content_raw
        )

      last_seen_before =
        RC.Repo.one(
          from(cp in RC.Messenger.ConversationMember,
            where: cp.profile_id == ^profile2.id,
            select: cp.last_seen
          )
        )

      :timer.sleep(1000)

      %{"message" => _message, "cid" => conversation_id} = json_response(conn, 201)

      build_api_conn()
      |> login(account2)
      |> get(Routes.messenger_path(conn, :index_messages, profile2.id, conversation_id))

      last_seen_after =
        RC.Repo.one(
          from(cp in RC.Messenger.ConversationMember,
            where: cp.profile_id == ^profile2.id,
            select: cp.last_seen
          )
        )

      assert last_seen_before < last_seen_after
    end
  end

  describe "send profile group" do
    setup [:create_three_accounts, :create_instance]

    test "returns message_sent when send a message", %{
      conn: conn,
      accounts: %{
        account1: account1,
        account2: account2,
        profile1: profile1,
        profile2: profile2,
        profile3: profile3
      }
    } do
      conn =
        conn
        |> login(account1)
        |> post(Routes.messenger_path(conn, :create_conv_group, profile1.id),
          profiles_ids: [profile2.id, profile3.id],
          content_raw: @message_attrs.content_raw,
          name: "TODO"
        )

      %{"cid" => cid} = json_response(conn, 201)

      conn =
        build_api_conn()
        |> login(account2)
        |> post(Routes.messenger_path(conn, :send_to_conv, profile2.id, cid),
          content_raw: @message_attrs.content_raw
        )

      assert resp = json_response(conn, 201)
      assert resp["message"] == "message_sent"
      assert resp["cid"] == cid
      assert resp["content_html"] == Markdown.render_inline(@message_attrs.content_raw)
    end

    test "returns forbidden if profile not in conversation", %{
      conn: conn,
      accounts: %{
        account1: account1,
        account2: account2,
        profile1: profile1,
        profile2: profile2,
        profile3: profile3
      }
    } do
      conn =
        conn
        |> login(account1)
        |> post(Routes.messenger_path(conn, :create_conv_group, profile1.id),
          profiles_ids: [profile3.id],
          content_raw: @message_attrs.content_raw,
          name: "TODO"
        )

      %{"cid" => cid} = json_response(conn, 201)

      conn =
        build_api_conn()
        |> login(account2)
        |> post(Routes.messenger_path(conn, :send_to_conv, profile2.id, cid),
          content_raw: @message_attrs.content_raw
        )

      assert resp = json_response(conn, 403)
      assert resp["message"] == "forbidden"
    end

    test "returns forbidden if conversation doesn't exists", %{
      conn: conn,
      accounts: %{
        account2: account2,
        profile2: profile2
      }
    } do
      conn =
        build_api_conn()
        |> login(account2)
        |> post(Routes.messenger_path(conn, :send_to_conv, profile2.id, 0),
          content_raw: @message_attrs.content_raw
        )

      assert resp = json_response(conn, 403)
      assert resp["message"] == "forbidden"
    end
  end

  describe "send profile group scoped to an instance" do
    setup [:create_three_accounts, :create_instance]

    test "returns message_sent when send a message", %{
      conn: conn,
      accounts: %{
        account1: account1,
        account2: account2,
        profile1: profile1,
        profile2: profile2,
        profile3: profile3
      },
      instance: instance
    } do
      conn =
        conn
        |> login(account1)
        |> post(Routes.messenger_path(conn, :create_conv_group, profile1.id, instance.id),
          profiles_ids: [profile2.id, profile3.id],
          content_raw: @message_attrs.content_raw,
          name: "TODO"
        )

      %{"cid" => cid} = json_response(conn, 201)

      conn =
        build_api_conn()
        |> login(account2)
        |> post(Routes.messenger_path(conn, :send_to_conv, profile2.id, cid),
          content_raw: @message_attrs.content_raw
        )

      assert resp = json_response(conn, 201)
      assert resp["message"] == "message_sent"
      assert resp["cid"] == cid
      assert resp["content_html"] == Markdown.render_inline(@message_attrs.content_raw)
    end

    test "returns forbidden if profile not in conversation", %{
      conn: conn,
      accounts: %{
        account1: account1,
        account2: account2,
        profile1: profile1,
        profile2: profile2,
        profile3: profile3
      },
      instance: instance
    } do
      conn =
        conn
        |> login(account1)
        |> post(Routes.messenger_path(conn, :create_conv_group, profile1.id, instance.id),
          profiles_ids: [profile3.id],
          content_raw: @message_attrs.content_raw,
          name: "TODO"
        )

      %{"cid" => cid} = json_response(conn, 201)

      conn =
        build_api_conn()
        |> login(account2)
        |> post(Routes.messenger_path(conn, :send_to_conv, profile2.id, cid),
          content_raw: @message_attrs.content_raw
        )

      assert resp = json_response(conn, 403)
      assert resp["message"] == "forbidden"
    end

    test "returns forbidden if conversation doesn't exists", %{
      conn: conn,
      accounts: %{
        account2: account2,
        profile2: profile2
      }
    } do
      conn =
        build_api_conn()
        |> login(account2)
        |> post(Routes.messenger_path(conn, :send_to_conv, profile2.id, 0),
          content_raw: @message_attrs.content_raw
        )

      assert resp = json_response(conn, 403)
      assert resp["message"] == "forbidden"
    end
  end

  describe "add profile" do
    setup [:create_three_accounts, :create_instance]

    test "returns profile_added when add a profile", %{
      conn: conn,
      accounts: %{
        account1: account1,
        profile1: profile1,
        profile2: profile2,
        profile3: profile3
      },
      instance: instance
    } do
      conn =
        conn
        |> login(account1)
        |> post(Routes.messenger_path(conn, :create_conv_group, profile1.id, instance.id),
          profiles_ids: [profile2.id],
          content_raw: @message_attrs.content_raw,
          name: "TODO"
        )

      %{"cid" => cid} = json_response(conn, 201)

      conn =
        build_api_conn()
        |> login(account1)
        |> put(Routes.messenger_path(conn, :add_profile, profile1.id, cid, profile3.id))

      assert resp = json_response(conn, 200)
      assert resp["message"] == "profile_added_to_conversation"
    end

    test "returns error when bad conversation id", %{
      conn: conn,
      accounts: %{
        account1: account1,
        profile1: profile1,
        profile2: profile2,
        profile3: profile3
      },
      instance: instance
    } do
      conn =
        conn
        |> login(account1)
        |> post(Routes.messenger_path(conn, :create_conv_group, profile1.id, instance.id),
          profiles_ids: [profile2.id],
          content_raw: @message_attrs.content_raw,
          name: "TODO"
        )

      %{"cid" => cid} = json_response(conn, 201)

      conn =
        build_api_conn()
        |> login(account1)
        |> put(Routes.messenger_path(conn, :add_profile, profile1.id, cid * 2, profile3.id))

      assert resp = json_response(conn, 403)
      assert resp["message"] == "forbidden"
    end

    test "returns error when bad profile id", %{
      conn: conn,
      accounts: %{
        account1: account1,
        profile1: profile1,
        profile2: profile2,
        profile3: profile3
      },
      instance: instance
    } do
      conn =
        conn
        |> login(account1)
        |> post(Routes.messenger_path(conn, :create_conv_group, profile1.id, instance.id),
          profiles_ids: [profile2.id],
          content_raw: @message_attrs.content_raw,
          name: "TODO"
        )

      %{"cid" => cid} = json_response(conn, 201)

      conn =
        build_api_conn()
        |> login(account1)
        |> put(Routes.messenger_path(conn, :add_profile, profile1.id, cid, profile3.id * 2))

      assert resp = json_response(conn, 403)
      assert resp["message"] == "error"
    end

    test "returns error when not admin", %{
      conn: conn,
      accounts: %{
        account1: account1,
        account2: account2,
        profile1: profile1,
        profile2: profile2,
        profile3: profile3
      },
      instance: instance
    } do
      conn =
        conn
        |> login(account1)
        |> post(Routes.messenger_path(conn, :create_conv_group, profile1.id, instance.id),
          profiles_ids: [profile2.id],
          content_raw: @message_attrs.content_raw,
          name: "TODO"
        )

      %{"cid" => cid} = json_response(conn, 201)

      conn =
        build_api_conn()
        |> login(account2)
        |> put(Routes.messenger_path(conn, :add_profile, profile1.id, cid, profile3.id))

      assert resp = json_response(conn, 403)
      assert resp["message"] == "forbidden"
    end
  end

  describe "remove profile" do
    setup [:create_three_accounts, :create_instance]

    test "remove selected profile when admin", %{
      conn: conn,
      accounts: %{
        account1: account1,
        profile1: profile1,
        profile2: profile2,
        profile3: profile3
      },
      instance: instance
    } do
      conn =
        conn
        |> login(account1)
        |> post(Routes.messenger_path(conn, :create_conv_group, profile1.id, instance.id),
          profiles_ids: [profile2.id, profile3.id],
          content_raw: @message_attrs.content_raw,
          name: "TODO"
        )

      %{"cid" => cid} = json_response(conn, 201)

      conn =
        build_api_conn()
        |> login(account1)
        |> delete(Routes.messenger_path(conn, :remove_profile, profile1.id, cid, profile2.id))

      assert response(conn, 200)
      assert nil == Messenger.get_conversation_member(cid, profile2.id)
      assert RC.Repo.aggregate(RC.Messenger.ConversationMember, :count, :id) == 2
    end

    test "returns forbidden when not admin", %{
      conn: conn,
      accounts: %{
        account1: account1,
        account3: account3,
        profile1: profile1,
        profile2: profile2,
        profile3: profile3
      },
      instance: instance
    } do
      conn =
        conn
        |> login(account1)
        |> post(Routes.messenger_path(conn, :create_conv_group, profile1.id, instance.id),
          profiles_ids: [profile2.id, profile3.id],
          content_raw: @message_attrs.content_raw,
          name: "TODO"
        )

      %{"cid" => cid} = json_response(conn, 201)

      conn =
        build_api_conn()
        |> login(account3)
        |> delete(Routes.messenger_path(conn, :remove_profile, profile3.id, cid, profile2.id))

      assert json_response(conn, 403)
      assert RC.Repo.aggregate(RC.Messenger.ConversationMember, :count, :id) == 3
    end
  end

  describe "list conversations by instance" do
    setup [:create_three_accounts, :create_instance]

    @faction_valid_attrs %{
      capacity: 42,
      faction_ref: "some faction_ref",
      registrations_count: 42
    }

    test "return existing conversation between profiles", %{
      conn: conn,
      accounts: %{
        account1: account1,
        account2: account2,
        profile1: profile1,
        profile2: profile2,
        profile3: profile3
      },
      instance: instance
    } do
      {:ok, faction} =
        %RC.Instances.Faction{}
        |> RC.Instances.Faction.changeset(@faction_valid_attrs)
        |> Ecto.Changeset.put_assoc(:instance, instance)
        |> Repo.insert()

      {:ok, _} = RC.Registrations.register_profile(faction, profile1)
      {:ok, _} = RC.Registrations.register_profile(faction, profile2)
      {:ok, _} = RC.Registrations.register_profile(faction, profile3)

      # create profile conversation between profile 1 and 2
      conn =
        conn
        |> login(account2)
        |> post(
          Routes.messenger_path(conn, :send_or_create_conv, profile2.id, instance.id),
          to: profile1.id,
          content_raw: @message_attrs.content_raw
        )

      # listing the conversation in instance
      conn =
        build_api_conn()
        |> login(account1)
        |> get(Routes.messenger_path(conn, :index_by_instance, profile1.id, instance.id))

      assert resp = json_response(conn, 200)

      [%RC.Messenger.Conversation{} = profile_conv | _] =
        RC.Repo.all(from(c in Conversation, where: c.is_group == false))

      assert conn.assigns.conversations.total_entries == 1

      [conv] = resp

      assert conv["id"] == profile_conv.id
      assert conv["is_group"] == profile_conv.is_group
      assert conv["name"] == profile_conv.name
      assert conv["unread"] == 1
    end
  end
end
