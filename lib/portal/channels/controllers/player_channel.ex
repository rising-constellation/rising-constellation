defmodule Portal.Controllers.PlayerChannel do
  use Phoenix.Channel
  use Portal.ReplayRecorder

  require Logger

  alias Portal.ChannelWatcher
  alias Instance.Galaxy.Galaxy

  def join("instance:player:" <> channel_data, %{"registration" => registration_token}, socket) do
    [instance_id, player_id] =
      channel_data
      |> String.split(":")
      |> Enum.map(&String.to_integer/1)

    if Instance.Manager.created?(instance_id) do
      {:ok, galaxy} = Game.call(instance_id, :galaxy, :master, :get_state)
      {:ok, time} = Game.call(instance_id, :time, :master, :get_state)

      has_replay =
        not (time.speed == :fast or Galaxy.is_tutorial(galaxy) or Application.get_env(:rc, :environment) == :test)

      {profile_id, faction_id, registration_id} =
        if Galaxy.is_tutorial(galaxy) do
          {galaxy.tutorial_id, 1, nil}
        else
          case RC.Registrations.valid?(instance_id, registration_token) do
            {:ok, registration} -> {registration.profile_id, registration.faction_id, registration.id}
            {:error, _} -> {false, nil, nil}
          end
        end

      if profile_id do
        if Galaxy.is_tutorial(galaxy) or profile_id == player_id do
          # set client status
          send(self(), :after_join)

          # assign ids to socket
          socket =
            socket
            |> assign(:instance_id, instance_id)
            |> assign(:registration_id, registration_id)
            |> assign(:faction_id, faction_id)
            |> assign(:player_id, player_id)
            |> assign(:channel_name, "player")
            |> assign(:is_tutorial, Galaxy.is_tutorial(galaxy))
            |> assign(:has_replay, has_replay)

          {:ok, player} = Game.call(instance_id, :player, player_id, :get_state)
          Portal.Socket.gc(socket)
          {:ok, %{player_player: player}, socket}
        else
          {:error, %{reason: "invalid_registration (player id doesn't match)"}}
        end
      else
        {:error, %{reason: "invalid_registration (player)"}}
      end
    else
      {:error, %{reason: "instance_not_instantiated"}}
    end
  end

  def handle_info(:after_join, socket) do
    instance_id = socket.assigns.instance_id
    player_id = socket.assigns.player_id
    :ok = ChannelWatcher.monitor(:player_channel, self(), {__MODULE__, :leave, [instance_id, player_id]})
    Game.call(instance_id, :player, player_id, {:update_client_status, :connect})
    {:noreply, socket}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  @doc """
  Called by ChannelWatcher when the channel process (self()) for a player dies
  """
  def leave(instance_id, player_id) do
    Game.call(instance_id, :player, player_id, {:update_client_status, :disconnect})
  end

  record(
    "order_building",
    %{
      "system_id" => system_id,
      "production_data" => %{
        "type" => type,
        "target_id" => target_id,
        "tile_id" => tile_id,
        "prod_key" => prod_key,
        "prod_level" => prod_level
      }
    },
    socket
  ) do
    query = {:order_building, system_id, type, {target_id, tile_id, String.to_existing_atom(prod_key), prod_level}}

    case Game.call(iid(socket), :player, pid(socket), query) do
      {:error, reason} -> {:error, %{reason: reason}}
      _ -> :ok
    end
  end

  record(
    "order_ship",
    %{
      "system_id" => system_id,
      "production_data" => %{"target_id" => target_id, "tile_id" => tile_id, "prod_key" => prod_key}
    },
    socket
  ) do
    query = {:order_ship, system_id, {target_id, tile_id, String.to_existing_atom(prod_key), 1}}

    case Game.call(iid(socket), :player, pid(socket), query) do
      {:error, reason} -> {:error, %{reason: reason}}
      _ -> :ok
    end
  end

  record(
    "remove_building",
    %{"system_id" => system_id, "production_data" => %{"target_id" => target_id, "tile_id" => tile_id}},
    socket
  ) do
    case Game.call(iid(socket), :player, pid(socket), {:remove_building, system_id, {target_id, tile_id}}) do
      {:error, reason} -> {:error, %{reason: reason}}
      _ -> :ok
    end
  end

  record("cancel_production", %{"system_id" => system_id, "production_id" => production_id}, socket) do
    case Game.call(iid(socket), :player, pid(socket), {:cancel_production, system_id, production_id}) do
      {:error, reason} -> {:error, %{reason: reason}}
      _ -> :ok
    end
  end

  record("purchase_patent", %{"patent_key" => patent_key}, socket) do
    patent_key = String.to_existing_atom(patent_key)

    case Game.call(iid(socket), :player, pid(socket), {:purchase_patent, patent_key}) do
      {:error, reason} -> {:error, %{reason: reason}}
      _ -> :ok
    end
  end

  record("purchase_doctrine", %{"doctrine_key" => doctrine_key}, socket) do
    doctrine_key = String.to_existing_atom(doctrine_key)

    case Game.call(iid(socket), :player, pid(socket), {:purchase_doctrine, doctrine_key}) do
      {:error, reason} -> {:error, %{reason: reason}}
      _ -> :ok
    end
  end

  record("purchase_policy_slot", %{}, socket) do
    case Game.call(iid(socket), :player, pid(socket), :purchase_policy_slot) do
      {:error, reason} -> {:error, %{reason: reason}}
      _ -> :ok
    end
  end

  record("update_policies", %{"doctrines_key" => doctrines_key}, socket) do
    doctrines_key = Enum.map(doctrines_key, fn d -> String.to_existing_atom(d) end)

    case Game.call(iid(socket), :player, pid(socket), {:update_policies, doctrines_key}) do
      {:error, reason} -> {:error, %{reason: reason}}
      _ -> :ok
    end
  end

  record("hire_character", %{"character" => character}, socket) do
    case Game.call(iid(socket), :player, pid(socket), {:hire_character, character}) do
      {:error, reason} -> {:error, %{reason: reason}}
      _ -> :ok
    end
  end

  record("dismiss_character", %{"character_id" => character_id}, socket) do
    case Game.call(iid(socket), :player, pid(socket), {:dismiss_character, character_id}) do
      {:error, reason} -> {:error, %{reason: reason}}
      _ -> :ok
    end
  end

  record("activate_character", %{"character_id" => character_id, "mode" => mode, "system_id" => system_id}, socket) do
    mode = String.to_existing_atom(mode)

    case Game.call(iid(socket), :player, pid(socket), {:activate_character, character_id, mode, system_id}) do
      {:error, reason} -> {:error, %{reason: reason}}
      _ -> :ok
    end
  end

  record("deactivate_character", %{"character_id" => character_id}, socket) do
    case Game.call(iid(socket), :player, pid(socket), {:deactivate_character, character_id}) do
      {:error, reason} -> {:error, %{reason: reason}}
      _ -> :ok
    end
  end

  record("add_character_actions", %{"character_id" => character_id, "actions" => actions}, socket) do
    case Game.call(iid(socket), :player, pid(socket), {:add_character_actions, character_id, actions}) do
      {:error, reason} -> {:error, %{reason: reason}}
      _ -> :ok
    end
  end

  record("clear_character_actions", %{"character_id" => character_id, "index" => index}, socket) do
    case Game.call(iid(socket), :player, pid(socket), {:clear_character_actions, character_id, index}) do
      {:error, reason} -> {:error, %{reason: reason}}
      _ -> :ok
    end
  end

  record("get_character", %{"character_id" => character_id}, socket) do
    case Game.call(iid(socket), :player, pid(socket), {:get_character_state, character_id}) do
      {:error, reason} -> {:error, %{reason: reason}}
      character -> {:ok, %{character: character}}
    end
  end

  record("update_reaction", %{"character_id" => character_id, "reaction" => reaction}, socket) do
    reaction = String.to_existing_atom(reaction)

    case Game.call(iid(socket), :player, pid(socket), {:update_reaction, character_id, reaction}) do
      {:error, reason} -> {:error, %{reason: reason}}
      _ -> :ok
    end
  end

  record("destroy_ship", %{"character_id" => character_id, "tile_id" => tile_id}, socket) do
    case Game.call(iid(socket), :player, pid(socket), {:destroy_ship, character_id, tile_id}) do
      {:error, reason} -> {:error, %{reason: reason}}
      _ -> :ok
    end
  end

  record("transform_system_to_dominion", %{"system_id" => system_id}, socket) do
    case Game.call(iid(socket), :player, pid(socket), {:transform_system_to_dominion, system_id}) do
      {:error, reason} -> {:error, %{reason: reason}}
      _ -> :ok
    end
  end

  record("transform_dominion_to_system", %{"system_id" => system_id}, socket) do
    case Game.call(iid(socket), :player, pid(socket), {:transform_dominion_to_system, system_id}) do
      {:error, reason} -> {:error, %{reason: reason}}
      _ -> :ok
    end
  end

  record("abandon_system", %{"system_id" => system_id}, socket) do
    case Game.call(iid(socket), :player, pid(socket), {:abandon_system, system_id}) do
      {:error, reason} -> {:error, %{reason: reason}}
      _ -> :ok
    end
  end

  record("abandon_dominion", %{"system_id" => system_id}, socket) do
    case Game.call(iid(socket), :player, pid(socket), {:abandon_dominion, system_id}) do
      {:error, reason} -> {:error, %{reason: reason}}
      _ -> :ok
    end
  end

  record("get_offers", %{}, socket) do
    offers =
      unless socket.assigns.is_tutorial,
        do: RC.Offers.get_offers(iid(socket), pid(socket), fid(socket)),
        else: []

    offers = Enum.map(offers, fn o -> %{o | inserted_at: DateTime.to_string(o.inserted_at)} end)
    {:ok, %{offers: offers}}
  end

  record("get_own_offers", %{}, socket) do
    offers =
      unless socket.assigns.is_tutorial,
        do: RC.Offers.get_own_offers(iid(socket), pid(socket)),
        else: []

    offers = Enum.map(offers, fn o -> %{o | inserted_at: DateTime.to_string(o.inserted_at)} end)
    {:ok, %{offers: offers}}
  end

  record("cancel_offer", %{"offer_id" => offer_id}, socket) do
    unless socket.assigns.is_tutorial do
      case Game.call(iid(socket), :player, pid(socket), {:cancel_offer, offer_id}) do
        {:error, reason} -> {:error, %{reason: reason}}
        :ok -> :ok
      end
    else
      {:error, %{reason: :feature_not_available}}
    end
  end

  record("buy_offer", %{"offer_id" => offer_id}, socket) do
    unless socket.assigns.is_tutorial do
      case Game.call(iid(socket), :player, pid(socket), {:buy_offer, offer_id}) do
        {:error, reason} -> {:error, %{reason: reason}}
        :ok -> :ok
      end
    else
      {:error, %{reason: :feature_not_available}}
    end
  end

  record("create_offer", offer_data, socket) do
    unless socket.assigns.is_tutorial do
      case Game.call(iid(socket), :player, pid(socket), {:create_offer, offer_data}) do
        {:error, reason} -> {:error, %{reason: reason}}
        :ok -> :ok
      end
    else
      {:error, %{reason: :feature_not_available}}
    end
  end

  record("get_reports", %{}, socket) do
    reports =
      unless socket.assigns.is_tutorial,
        do: RC.PlayerReports.by_registration(socket.assigns.registration_id),
        else: []

    {:ok, %{reports: reports}}
  end

  record("hide_report", %{"report_id" => report_id}, socket) do
    unless socket.assigns.is_tutorial do
      RC.PlayerReports.hide(socket.assigns.registration_id, report_id)
    end

    :ok
  end

  record("get_events", %{"page" => page}, socket) do
    unless socket.assigns.is_tutorial do
      result = RC.PlayerEvents.get_for_player(socket.assigns, page: page)
      events = Enum.map(result.entries, fn e -> %{e | inserted_at: DateTime.to_string(e.inserted_at)} end)
      {:ok, %{events: events, total_pages: result.total_pages, page_number: result.page_number}}
    else
      {:ok, %{}}
    end
  end

  def broadcast_change(channel, payload) do
    Portal.Endpoint.broadcast(channel, "broadcast", payload)
  end

  defp iid(socket), do: socket.assigns.instance_id
  defp pid(socket), do: socket.assigns.player_id
  defp fid(socket), do: socket.assigns.faction_id
end
