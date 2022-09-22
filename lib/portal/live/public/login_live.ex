defmodule Portal.LoginLive do
  use Portal, :live_view

  alias RC.Accounts

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, validated: false, email: nil, password: nil)}
  end

  @impl true
  def handle_event("login", %{"account" => account}, socket) do
    login_mode = Portal.Config.fetch_key(:login_mode)
    email = Map.get(account, "email")
    password = Map.get(account, "password")

    case Accounts.get_account_by_email_and_password(email, password) do
      {:ok, account} ->
        if login_mode == :disabled and account.role != :admin do
          {:noreply, put_flash(socket, :error, :connection_disabled)}
        else
          socket =
            socket
            |> assign(validated: true)
            |> assign(email: email)
            |> assign(password: password)

          {:noreply, socket}
        end

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "The email address is unknown or the password is wrong.")}
    end
  end
end
