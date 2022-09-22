defmodule Portal.Controllers.GlobalChannel do
  use Phoenix.Channel
  use Portal.ReplayRecorder

  alias Instance.Galaxy.Galaxy

  def join("instance:global:" <> instance_id, %{"registration" => registration_token}, socket) do
    instance_id = instance_id |> String.to_integer()

    if Instance.Manager.created?(instance_id) do
      {:ok, galaxy} = Game.call(instance_id, :galaxy, :master, :get_state)
      {:ok, time} = Game.call(instance_id, :time, :master, :get_state)

      has_replay =
        not (time.speed == :fast or Galaxy.is_tutorial(galaxy) or Application.get_env(:rc, :environment) == :test)

      profile_id =
        if Galaxy.is_tutorial(galaxy) do
          galaxy.tutorial_id
        else
          case RC.Registrations.valid?(instance_id, registration_token) do
            {:ok, registration} -> registration.profile_id
            {:error, _} -> false
          end
        end

      if profile_id do
        socket =
          socket
          |> assign(:instance_id, instance_id)
          |> assign(:player_id, profile_id)
          |> assign(:channel_name, "global")
          |> assign(:is_tutorial, Galaxy.is_tutorial(galaxy))
          |> assign(:has_replay, has_replay)

        {:ok, victory} = Game.call(instance_id, :victory, :master, :get_state)
        {:ok, character_market} = Game.call(instance_id, :character_market, :master, :get_state)

        # join payload is huge, garbage collect after a few seconds
        Portal.Socket.gc(socket)

        payload = %{
          global_data: Data.Querier.get_data(instance_id),
          global_galaxy: galaxy,
          global_time: time,
          global_victory: victory,
          global_character_market: character_market
        }

        {:ok, payload, socket}
      else
        {:error, %{reason: "invalid_registration"}}
      end
    else
      {:error, %{reason: "instance_not_found"}}
    end
  end

  def handle_info(_, socket), do: {:noreply, socket}

  record("get_player", %{"player_id" => player_id}, socket) do
    {:ok, public_player} = Game.call(socket.assigns.instance_id, :player, player_id, :get_public_state)
    {:ok, %{player: public_player}}
  end

  record("get_stats", %{}, socket) do
    stats =
      unless socket.assigns.is_tutorial,
        do: RC.PlayerStats.get_last_player_stat_by_instance_id(socket.assigns.instance_id),
        else: []

    {:ok, %{players: stats}}
  end

  record("kill_instance", %{}, socket) do
    if socket.assigns.is_tutorial do
      spawn(fn ->
        Process.sleep(10_000)
        Instance.Manager.destroy(socket.assigns.instance_id)
      end)

      {:ok, :killed}
    else
      {:error, :unable_to_kill}
    end
  end

  def broadcast_change(channel, payload) do
    Portal.Endpoint.broadcast(channel, "broadcast", payload)
  end
end
