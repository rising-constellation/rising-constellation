defmodule Portal.SettingsLive do
  use Portal, :admin_live_view

  alias Portal.Config
  alias RC.Maintenance

  @impl true
  def mount(_params, session, socket) do
    {:ok,
     assign(socket,
       current_user: RC.Guardian.resource_from_session(session),
       signup_mode: Config.fetch_key(:signup_mode),
       signup_modes: Config.signup_modes(),
       login_mode: Config.fetch_key(:login_mode),
       login_modes: Config.login_modes(),
       maintenance_log: Maintenance.get_latest() |> Maintenance.Log.changeset(%{})
     )}
  end

  @impl true
  def handle_event("update", %{"mode" => mode, "type" => "signup"}, socket) do
    case Config.prepare_signup_mode(mode) do
      {:ok, mode} ->
        Config.update_key(:signup_mode, mode)
        {:noreply, assign(socket, signup_mode: mode)}

      {:error, :invalid_signup_mode} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("update", %{"mode" => mode, "type" => "login"}, socket) do
    case Config.prepare_login_mode(mode) do
      {:ok, mode} ->
        Config.update_key(:login_mode, mode)
        {:noreply, assign(socket, login_mode: mode)}

      {:error, :invalid_login_mode} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("update_version", %{"log" => %{"min_client_version" => version}}, socket) do
    socket = clear_flash(socket)

    case Maintenance.set_version(version, socket.assigns.current_user.id) do
      {:ok, maintenance_log} ->
        maintenance_log = Maintenance.Log.changeset(maintenance_log, %{})
        socket = socket |> assign(maintenance_log: maintenance_log) |> put_flash(:info, "Version updated")
        {:noreply, socket}

      {:error, _err} ->
        {:noreply, put_flash(socket, :error, "Invalid version")}
    end
  end
end
