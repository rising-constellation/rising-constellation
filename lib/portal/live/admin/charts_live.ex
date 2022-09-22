defmodule Portal.ChartsLive do
  use Portal, :admin_live_view

  require Logger

  alias RC.PlayerStats
  alias RC.Registrations

  @impl true
  def mount(%{"iid" => iid}, _session, socket) do
    registrations = Registrations.list(iid)

    checked = []

    socket =
      socket
      |> assign(:registrations, registrations)
      |> assign(:checked, checked)
      |> assign(:stats, [])
      |> assign(:iid, String.to_integer(iid))

    {:ok, socket}
  end

  @impl true
  def handle_event("toggle", %{"toggle-id" => id}, socket) do
    id = String.to_integer(id)
    checked = socket.assigns.checked

    checked =
      if id in checked do
        Enum.reject(checked, &(&1 == id))
      else
        [id | checked]
      end

    stats = PlayerStats.get_players_stats_by_instance_id(socket.assigns.iid, checked)

    socket =
      socket
      |> assign(:checked, checked)
      |> assign(:stats, stats)

    {:noreply, socket}
    {:noreply, push_event(socket, "stats", stats)}
  end
end
