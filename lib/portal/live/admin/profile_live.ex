defmodule Portal.ProfileLive do
  use Portal, :admin_live_view

  alias RC.Accounts

  @impl true
  def handle_params(params, _, socket) do
    profile = Accounts.get_profile_preload(Map.get(params, "pid"))

    if profile != nil do
      {:noreply, assign(socket, profile: profile)}
    else
      IO.inspect("profile not found")
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("update", params, socket) do
    pid = Map.get(params, "pid")
    profile = Accounts.get_profile(pid)

    case Accounts.update_profile(profile, params) do
      {:ok, profile} ->
        profile = Accounts.get_profile_preload(profile.id)
        {:noreply, assign(socket, profile: profile)}

      {:error, _} ->
        IO.inspect("profile not found")
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("delete", params, socket) do
    {pid, params} = Map.pop(params, "pid")
    profile = Accounts.get_profile(pid)

    case Accounts.update_profile(profile, params) do
      {:ok, profile} ->
        profile = Accounts.get_profile_preload(profile.id)
        {:noreply, assign(socket, profile: profile)}

      {:error, _} ->
        IO.inspect("profile not found")
        {:noreply, socket}
    end
  end
end
