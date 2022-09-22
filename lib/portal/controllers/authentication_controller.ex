defmodule Portal.AuthenticationController do
  use Portal, :controller

  alias RC.Accounts
  alias RC.Logs

  require Logger

  plug(Ueberauth)

  def identity_callback(conn, %{"steam_id" => steam_id, "ticket" => ticket}) do
    case Accounts.get_account_by_steam_ticket(steam_id, ticket) do
      {:ok, account} ->
        handle_account_conn(conn, account)

      {:error, reason} ->
        Logger.info("#{inspect(reason)}")

        conn
        |> put_status(401)
        |> json(%{message: :account_not_found})
    end
  end

  def identity_callback(%{assigns: %{ueberauth_auth: %{uid: email, credentials: credentials}}} = conn, _params) do
    login_mode = Portal.Config.fetch_key(:login_mode)
    email = String.trim(email)
    password = credentials.other.password

    case Accounts.get_account_by_email_and_password(email, password) do
      {:ok, account} ->
        if login_mode == :disabled and account.role != :admin do
          conn
          |> put_status(401)
          |> json(%{message: :connection_disabled})
        else
          handle_account_conn(conn, account)
        end

      {:error, reason} ->
        Logger.info("#{inspect(reason)}")

        conn
        |> put_status(401)
        |> json(%{message: :account_not_found})
    end
  end

  def identity_callback(conn, _params) do
    conn
    |> put_status(401)
    |> json(%{message: :unauthorized})
  end

  def logout(conn, _) do
    conn
    |> RC.Guardian.Plug.sign_out()
    |> redirect(to: "/")
  end

  defp handle_account_conn(conn, account) do
    Logs.create_log(%{action: :login}, account)

    {:ok, jwt, _full_claims} = RC.Guardian.encode_and_sign(account, %{})

    conn
    |> RC.Guardian.Plug.sign_in(account)
    |> put_resp_header("authorization", "Bearer #{jwt}")
    |> json(%{token: jwt, account: account})
  end
end
