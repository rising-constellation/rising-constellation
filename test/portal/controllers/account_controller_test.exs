defmodule Portal.AccountControllerTest do
  use Portal.APIConnCase
  import RC.Fixtures

  alias RC.Accounts
  alias RC.Accounts.Account
  alias RC.Accounts.AccountToken
  alias RC.Groups
  alias RC.Logs.Log
  alias RC.Repo

  @name_too_long %{name: "VLfOpwEvyIm8wO3aAeu3F01z5xopKzxRyS1gbaaYKxQ63CBI0R6"}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create account" do
    test "get successful signup with mail validation when create account with valid data", %{conn: conn} do
      n_logs_before = Repo.aggregate(Log, :count, :id)
      n_account_before = Repo.aggregate(Account, :count, :id)
      n_token_before = Repo.aggregate(AccountToken, :count, :id)

      conn = post(conn, Routes.account_path(conn, :create), account: account_valid_user_attrs())

      n_logs_after = Repo.aggregate(Log, :count, :id)
      n_account_after = Repo.aggregate(Account, :count, :id)
      n_token_after = Repo.aggregate(AccountToken, :count, :id)

      assert %{"message" => "signup_with_mail"} == json_response(conn, 201)
      assert n_logs_before == n_logs_after - 1
      assert n_account_before == n_account_after - 1
      assert n_token_before == n_token_after - 1
    end

    test "get successful signup with manual validation when create account with valid data", %{conn: conn} do
      Portal.Config.update_key(:signup_mode, :manual_validation)
      conn = post(conn, Routes.account_path(conn, :create), account: account_valid_user_attrs())

      # reset config
      Portal.Config.update_key(:signup_mode, Application.get_env(:rc, :signup_mode))
      assert %{"message" => "signup_with_validation"} == json_response(conn, 201)
    end

    test "get error signup when bad email", %{conn: conn} do
      n_logs_before = Repo.aggregate(Log, :count, :id)
      n_account_before = Repo.aggregate(Account, :count, :id)
      n_token_before = Repo.aggregate(AccountToken, :count, :id)

      conn = post(conn, Routes.account_path(conn, :create), account: account_invalid_email_attrs())

      n_logs_after = Repo.aggregate(Log, :count, :id)
      n_account_after = Repo.aggregate(Account, :count, :id)
      n_token_after = Repo.aggregate(AccountToken, :count, :id)

      assert json_response(conn, 400)["message"]["email"] == ["has invalid format"]
      assert n_logs_before == n_logs_after
      assert n_account_before == n_account_after
      assert n_token_before == n_token_after
    end

    test "get error when name is too long", %{conn: conn} do
      n_logs_before = Repo.aggregate(Log, :count, :id)
      n_account_before = Repo.aggregate(Account, :count, :id)
      n_token_before = Repo.aggregate(AccountToken, :count, :id)

      conn =
        post(conn, Routes.account_path(conn, :create),
          account: account_valid_user_attrs() |> Map.put(:name, @name_too_long.name)
        )

      n_logs_after = Repo.aggregate(Log, :count, :id)
      n_account_after = Repo.aggregate(Account, :count, :id)
      n_token_after = Repo.aggregate(AccountToken, :count, :id)

      assert json_response(conn, 400)["message"]["name"] == ["should be at most 50 character(s)"]
      assert n_logs_before == n_logs_after
      assert n_account_before == n_account_after
      assert n_token_before == n_token_after
    end

    test "return error when signup are disabled", %{conn: conn} do
      Portal.Config.update_key(:signup_mode, :disabled)
      conn = post(conn, Routes.account_path(conn, :create), account: account_valid_user_attrs())

      # reset config
      Portal.Config.update_key(:signup_mode, Application.get_env(:rc, :signup_mode))
      assert %{"message" => "signup_disabled"} == json_response(conn, 403)
    end

    test "renders account when data is valid", %{conn: conn} do
      {:ok, account} = Accounts.create_account(account_valid_user_attrs())

      conn =
        conn
        |> login(account)
        |> get(Routes.account_path(conn, :show, account.id))

      assert %{
               "id" => _id,
               "email" => "user@user",
               "name" => "some name",
               "role" => "user",
               "status" => "registered"
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.account_path(conn, :create), account: account_invalid_attrs())

      assert json_response(conn, 400) ==
               %{
                 "message" => %{
                   "email" => ["can't be blank"],
                   "name" => ["can't be blank"],
                   "password" => ["can't be blank"]
                 }
               }
    end

    test "renders error if the email is already taken", %{conn: conn} do
      conn =
        conn
        |> post(Routes.account_path(conn, :create), account: account_valid_user_attrs())
        |> post(Routes.account_path(conn, :create),
          # |> Map.put(:email, "other@email")
          account: account_valid_user_attrs()
        )

      assert json_response(conn, 400)["message"]["email"] == ["has already been taken"]
    end
  end

  describe "update account as admin" do
    setup [:create_account_admin]

    test "renders account when data is valid", %{conn: conn, account: %Account{id: id} = account} do
      conn =
        conn
        |> login(account)
        |> put(Routes.account_path(conn, :update, account), account: account_update_attrs())

      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, Routes.account_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "email" => "updated@email",
               "name" => "some updated name",
               "role" => "user",
               "status" => "registered"
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> put(Routes.account_path(conn, :update, account), account: account_invalid_attrs())

      assert json_response(conn, 400)["message"]
    end

    test "renders errors when email is invalid", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> put(Routes.account_path(conn, :update, account), account: %{email: "invalid"})

      assert json_response(conn, 400)["message"]["email"] == ["has invalid format"]
    end
  end

  describe "update account as user" do
    setup [:create_account_user]

    test "renders account when data is valid", %{conn: conn, account: %Account{id: id} = account} do
      conn =
        conn
        |> login(account)
        |> put(Routes.account_path(conn, :update_restricted, account), account: account_update_attrs())

      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, Routes.account_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "email" => "updated@email",
               "name" => "some updated name",
               # no change
               "role" => "user",
               # no change
               "status" => "registered"
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> put(Routes.account_path(conn, :update_restricted, account), account: account_invalid_attrs())

      assert json_response(conn, 400)
    end

    test "gives unauthorized if update not restricted", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> put(Routes.account_path(conn, :update, account), account: account_update_attrs())

      assert %{"message" => "forbidden"} == json_response(conn, 403)
    end

    test "renders error when email is invalid", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> put(Routes.account_path(conn, :update_restricted, account), account: %{email: "invalid"})

      assert json_response(conn, 400)["message"]["email"] == ["has invalid format"]
    end

    test "renders error when new name is too long", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> put(Routes.account_path(conn, :update_restricted, account), account: @name_too_long)

      assert json_response(conn, 400)["message"]["name"] == ["should be at most 50 character(s)"]
    end

    test "creates a token if email is updated", %{conn: conn, account: account} do
      Portal.Config.update_key(:signup_mode, :email_verification)

      conn =
        conn
        |> login(account)
        |> put(Routes.account_path(conn, :update_restricted, account), account: %{email: "new@email"})

      # reset config
      Portal.Config.update_key(:signup_mode, Application.get_env(:rc, :signup_mode))
      assert json_response(conn, 200)
      assert [token] = Repo.all(AccountToken)
      assert token.candidate_email == "new@email"
      assert token.account_id == account.id
    end
  end

  describe "valide email update" do
    setup [:create_account_user]

    test "updates the email if the token is valid", %{conn: conn, account: account} do
      {:ok, token} =
        Repo.insert(
          AccountToken.changeset_email(%AccountToken{}, %{
            value: "test_email_update",
            type: :email_update,
            candidate_email: "new@email",
            account_id: account.id
          })
        )

      conn = post(conn, Routes.account_path(conn, :validate_update), %{token: token.value})

      account = Repo.get(Account, account.id)

      assert json_response(conn, 200)["message"] == "account_email_updated"
      assert account.email == token.candidate_email
    end

    test "returns a error if the token is invalid", %{conn: conn, account: account} do
      Portal.Config.update_key(:signup_mode, :email_verification)

      {:ok, _token} =
        Repo.insert(
          AccountToken.changeset_email(%AccountToken{}, %{
            value: "test_email_update",
            type: :email_update,
            candidate_email: "new@email",
            account_id: account.id
          })
        )

      # reset config
      Portal.Config.update_key(:signup_mode, Application.get_env(:rc, :signup_mode))

      conn = post(conn, Routes.account_path(conn, :validate_update), %{token: "test_email_update_wrong"})

      assert json_response(conn, 400)["message"] == "bad_or_expired_token"
    end
  end

  describe "delete account as user" do
    setup [:create_account_user]

    test "deletes own account", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> delete(Routes.account_path(conn, :delete, account))

      assert response(conn, 204)

      response = get(conn, Routes.account_path(conn, :show, account))
      assert response.status == 401
    end

    test "return error if not own account", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> delete(Routes.account_path(conn, :delete, account.id * 2))

      assert json_response(conn, 403)["message"] == "forbidden"
    end

    test "deletes account if in group", %{conn: conn, account: account} do
      group = fixture(:group)

      {:ok, _group_with_accounts} = Groups.insert_accounts(group, [account.id])

      conn =
        conn
        |> login(account)
        |> delete(Routes.account_path(conn, :delete, account))

      assert response(conn, 204)

      response = get(conn, Routes.account_path(conn, :show, account))
      assert response.status == 401

      assert Groups.list_groups().entries == [group]
    end
  end

  describe "delete account as admin" do
    setup [:create_account_admin]

    test "deletes own account", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> delete(Routes.account_path(conn, :delete, account))

      assert response(conn, 204)

      response = get(conn, Routes.account_path(conn, :show, account))
      assert response.status == 401
    end
  end

  describe "verify" do
    setup [:create_account_user_registered]

    test "verify account", %{conn: conn, account: account} do
      Accounts.create_account_token(%{
        value: "val",
        type: :email_verification,
        account_id: account.id
      })

      conn = post(conn, Routes.account_path(conn, :validate), %{token: "val"})

      assert json_response(conn, 200)["message"] == "account_validated"
    end

    test "does not verify account if invalid token", %{conn: conn, account: account} do
      Accounts.create_account_token(%{
        value: "val",
        type: :email_verification,
        account_id: account.id
      })

      conn = post(conn, Routes.account_path(conn, :validate), %{token: "invalid"})

      assert json_response(conn, 400)["message"] == "bad_or_expired_token"
    end

    test "does not verify if token is for password reset", %{conn: conn, account: account} do
      Accounts.create_account_token(%{
        value: "val",
        type: :password_reset,
        account_id: account.id
      })

      conn = post(conn, Routes.account_path(conn, :validate), %{token: "invalid"})

      assert json_response(conn, 400)["message"] == "bad_or_expired_token"
    end
  end

  describe "reset password" do
    setup [:create_account_user]

    test "verify account", %{conn: conn, account: account} do
      Accounts.create_account_token(%{
        value: "val",
        type: :password_reset,
        account_id: account.id
      })

      Accounts.update_account(account, %{status: :active})

      pw_before = Repo.get(Account, account.id).hashed_password

      conn = post(conn, Routes.account_path(conn, :reset_password), %{token: "val", new_password: "pw"})

      pw_after = Repo.get(Account, account.id).hashed_password

      assert json_response(conn, 200)["message"] == "password_reseted"
      assert pw_before != pw_after
    end

    test "does not reset account if invalid token", %{conn: conn, account: account} do
      Accounts.create_account_token(%{
        value: "val",
        type: :password_reset,
        account_id: account.id
      })

      Accounts.update_account(account, %{status: :active})

      conn = post(conn, Routes.account_path(conn, :reset_password), %{token: "invalid", new_password: "pw"})

      assert json_response(conn, 400)["message"] == "bad_or_expired_token"
    end

    test "does not verify if token is for email verification", %{conn: conn, account: account} do
      Accounts.create_account_token(%{
        value: "val",
        type: :email_verification,
        account_id: account.id
      })

      conn = post(conn, Routes.account_path(conn, :reset_password), %{token: "invalid", new_password: "pw"})

      assert json_response(conn, 400)["message"] == "bad_or_expired_token"
    end

    test "does not reset if account is not confirmed", %{conn: conn, account: account} do
      Accounts.create_account_token(%{
        value: "val",
        type: :password_reset,
        account_id: account.id
      })

      Accounts.update_account(account, %{status: :registered})
      conn = post(conn, Routes.account_path(conn, :reset_password), %{token: "val", new_password: "pw"})

      assert json_response(conn, 403)["message"] == "account_not_confirmed"
    end
  end

  describe "send password reset" do
    setup [:create_account_user]

    test "send reset password", %{conn: conn, account: account} do
      Accounts.update_account(account, %{status: :active})

      conn = post(conn, Routes.account_path(conn, :send_password_reset), %{email: account.email})

      assert json_response(conn, 200)["message"] == "password_reset_sent"
    end

    test "invalidate previous token when multiple resets", %{conn: conn, account: account} do
      Accounts.update_account(account, %{status: :active})

      conn = post(conn, Routes.account_path(conn, :send_password_reset), %{email: account.email})
      conn2 = post(conn, Routes.account_path(conn, :send_password_reset), %{email: account.email})

      assert json_response(conn, 200)["message"] == "password_reset_sent"
      assert json_response(conn2, 200)["message"] == "password_reset_sent"
      assert Repo.aggregate(AccountToken, :count) == 1
    end
  end

  describe "send email verification" do
    setup [:create_account_user]

    test "send reset password", %{conn: conn, account: account} do
      Accounts.update_account(account, %{status: :active})

      conn = post(conn, Routes.account_path(conn, :send_email_verification), %{email: account.email})

      assert json_response(conn, 200)["message"] == "email_verification_sent"
    end

    test "invalidate previous token when multiple resets", %{conn: conn, account: account} do
      Accounts.update_account(account, %{status: :active})

      conn = post(conn, Routes.account_path(conn, :send_email_verification), %{email: account.email})
      conn2 = post(conn, Routes.account_path(conn, :send_email_verification), %{email: account.email})

      assert json_response(conn, 200)["message"] == "email_verification_sent"
      assert json_response(conn2, 200)["message"] == "email_verification_sent"
      assert Repo.aggregate(AccountToken, :count) == 1
    end
  end

  describe "validate" do
    # setup [:create_account_user]

    import Ecto.Query, warn: false

    test "validate created account", %{conn: conn} do
      Process.sleep(1000)
      conn = post(conn, Routes.account_path(conn, :create), account: account_valid_user_attrs())

      assert json_response(conn, 201)["message"] == "signup_with_mail"

      email = account_valid_user_attrs().email

      account =
        Repo.one(
          from(a in Account,
            where: a.email == ^email
          )
        )

      token =
        Repo.one(
          from(t in AccountToken,
            where: t.account_id == ^account.id and t.type == :email_verification
          )
        )

      conn = post(conn, Routes.account_path(conn, :validate, token: token.value))

      assert json_response(conn, 200)["message"] == "account_validated"
    end

    test "validate with new verification email", %{conn: conn} do
      post(conn, Routes.account_path(conn, :create), account: account_valid_user_attrs())

      email = account_valid_user_attrs().email

      account =
        Repo.one(
          from(a in Account,
            where: a.email == ^email
          )
        )

      post(conn, Routes.account_path(conn, :send_email_verification), %{email: account.email})

      assert Repo.aggregate(AccountToken, :count) == 1

      token =
        Repo.one(
          from(t in AccountToken,
            where: t.account_id == ^account.id and t.type == :email_verification
          )
        )

      conn = post(conn, Routes.account_path(conn, :validate, token: token.value))

      assert json_response(conn, 200)["message"] == "account_validated"
    end

    test "does not validate if not last token", %{conn: conn} do
      {:ok, [account: account]} = create_account_user(%{})

      # Accounts.update_account(account, %{status: :active})
      conn = post(conn, Routes.account_path(conn, :send_email_verification), %{email: account.email})

      token1 =
        Repo.one(
          from(t in AccountToken,
            where: t.account_id == ^account.id and t.type == :email_verification
          )
        )

      post(conn, Routes.account_path(conn, :send_email_verification), %{email: account.email})

      token2 =
        Repo.one(
          from(t in AccountToken,
            where: t.account_id == ^account.id and t.type == :email_verification
          )
        )

      assert token1.value != token2.value

      conn = post(conn, Routes.account_path(conn, :validate, token: token1.value))

      assert json_response(conn, 400)["message"] == "bad_or_expired_token"
    end

    test "validate if last token", %{conn: conn} do
      {:ok, [account: account]} = create_account_user(%{})

      # Accounts.update_account(account, %{status: :active})
      conn = post(conn, Routes.account_path(conn, :send_email_verification), %{email: account.email})

      post(conn, Routes.account_path(conn, :send_email_verification), %{email: account.email})

      token2 =
        Repo.one(
          from(t in AccountToken,
            where: t.account_id == ^account.id and t.type == :email_verification
          )
        )

      conn = post(conn, Routes.account_path(conn, :validate, token: token2.value))

      assert json_response(conn, 200)["message"] == "account_validated"
    end
  end
end
