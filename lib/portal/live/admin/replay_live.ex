defmodule Portal.ReplayLive do
  use Portal, :admin_live_view

  require Logger

  alias RC.Replays

  @impl true
  def handle_params(%{"iid" => iid, "profile" => profile_id}, _, socket) do
    replay = Replays.admin_filter(iid, profile_id)

    if replay != nil do
      {:noreply, assign(socket, replay: replay, iid: iid)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_params(%{"iid" => iid}, _, socket) do
    replay = Replays.admin_filter(iid)

    if replay != nil do
      {:noreply, assign(socket, replay: replay, iid: iid)}
    else
      {:noreply, socket}
    end
  end
end
