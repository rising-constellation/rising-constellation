defmodule Portal.Controllers.FactionChannel do
  use Phoenix.Channel
  use Portal.ReplayRecorder

  alias Portal.Presence
  alias Instance.Galaxy.Galaxy

  def topic(%{instance_id: instance_id, faction_id: faction_id}) do
    "instance:faction:#{instance_id}:#{faction_id}"
  end

  def join("instance:faction:" <> channel_data, %{"registration" => registration_token}, socket) do
    [instance_id, faction_id] =
      channel_data
      |> String.split(":")
      |> Enum.map(&String.to_integer/1)

    if Instance.Manager.created?(instance_id) do
      {:ok, galaxy} = Game.call(instance_id, :galaxy, :master, :get_state)
      {:ok, time} = Game.call(instance_id, :time, :master, :get_state)

      has_replay =
        not (time.speed == :fast or Galaxy.is_tutorial(galaxy) or Application.get_env(:rc, :environment) == :test)

      {profile_id, registration} =
        if Galaxy.is_tutorial(galaxy) do
          {galaxy.tutorial_id, nil}
        else
          case RC.Registrations.valid?(instance_id, registration_token) do
            {:ok, registration} -> {registration.profile_id, registration}
            {:error, _} -> {false, nil}
          end
        end

      if profile_id do
        if Galaxy.is_tutorial(galaxy) or registration.faction_id == faction_id do
          send(self(), :after_join)

          # assign ids to socket
          socket =
            socket
            |> assign(:instance_id, instance_id)
            |> assign(:faction_id, faction_id)
            |> assign(:player_id, profile_id)
            |> assign(:channel_name, "faction")
            |> assign(:is_tutorial, Galaxy.is_tutorial(galaxy))
            |> assign(:has_replay, has_replay)

          {:ok, faction} = Game.call(instance_id, :faction, faction_id, :get_state)
          Portal.Socket.gc(socket)
          {:ok, %{faction_faction: faction}, socket}
        else
          {:error, %{reason: "invalid_registration (faction id doesn't match)"}}
        end
      else
        {:error, %{reason: "invalid_registration"}}
      end
    else
      {:error, %{reason: "instance_not_found"}}
    end
  end

  def handle_info(:after_join, socket) do
    {:ok, _} = Presence.track(socket, socket.assigns.player_id, %{})
    push(socket, "presence_state", Presence.list(socket))

    {:noreply, socket}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  record("get_system", %{"system_id" => system_id}, socket) do
    query = {:get_system_state, system_id}
    system_with_visibility = Game.call(socket.assigns.instance_id, :faction, socket.assigns.faction_id, query)

    {:ok, %{system: system_with_visibility}}
  end

  record("get_character", %{"character_id" => character_id}, socket) do
    query = {:get_character_state, character_id}
    character_with_visibility = Game.call(socket.assigns.instance_id, :faction, socket.assigns.faction_id, query)

    {:ok, %{character: character_with_visibility}}
  end

  record("push_chat_message", %{"from" => from, "message" => message}, socket) do
    Game.cast(socket.assigns.instance_id, :faction, socket.assigns.faction_id, {:push_message, from, message})
    :ok
  end

  record(
    "send_resources",
    %{"player_id" => to_player_id, "resources" => resources},
    socket
  ) do
    case Game.call(
           socket.assigns.instance_id,
           :faction,
           socket.assigns.faction_id,
           {:send_resources, socket.assigns.player_id, to_player_id, resources}
         ) do
      {:error, reason} -> {:error, %{reason: reason}}
      _ -> :ok
    end
  end

  def broadcast_change(channel, payload) do
    Portal.Endpoint.broadcast(channel, "broadcast", payload)
  end
end
