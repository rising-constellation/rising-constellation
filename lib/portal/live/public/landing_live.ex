defmodule Portal.LandingLive do
  use Portal, :live_view

  alias RC.Accounts

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:show_login, false)
      |> assign(:validated, false)
      |> assign(:email, nil)
      |> assign(:password, nil)

    {:ok, socket}
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

  @impl true
  def handle_event("show_login", _value, socket) do
    {:noreply, assign(socket, :show_login, true)}
  end

  @impl true
  def handle_event("show_signup", _value, socket) do
    {:noreply, assign(socket, :show_login, false)}
  end
end
