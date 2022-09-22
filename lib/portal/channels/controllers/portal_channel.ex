defmodule Portal.Controllers.PortalChannel do
  use Phoenix.Channel

  alias RC.Instances

  def join("portal:user:*", _data, socket) do
    {:ok, %{resp: "ok"}, socket}
  end

  def join("portal:user:" <> account_id, _data, socket) do
    if String.to_integer(account_id) == socket.assigns.account.id do
      {:ok, %{resp: "ok"}, socket}
    else
      {:error, :unauthorized}
    end
  end

  def join("portal:profile:" <> profile_id, _data, socket) do
    if RC.Accounts.own_profile?(socket.assigns.account.id, profile_id) do
      {:ok, %{resp: "ok"}, socket}
    else
      {:error, :unauthorized}
    end
  end

  def join("portal:instance:" <> instance_id, _data, socket) do
    instance_id = String.to_integer(instance_id)
    {:ok, %{resp: "ok"}, assign(socket, instance_id: instance_id)}
  end

  def handle_in("start", _params, socket) do
    account_id = socket.assigns.account.id
    instance_id = socket.assigns.instance_id

    resp =
      with instance when not is_nil(instance) <- Instances.get_instance_with_registration(instance_id),
           push(socket, "status", %{status: "step_0"}),
           state when state in ["open", "not_running"] <- instance.state,
           {:ok, :instantiated} <- Instance.Manager.create_from_model(instance, nil, "portal:user:#{account_id}"),
           {:ok, :started, _} <- Instance.Manager.call(instance.id, :start) do
        case state do
          "open" ->
            {:ok, %{registrations_errors: _registrations_errors_count}} = Instances.start_instance(instance, account_id)

            {:ok, %{resp: "Instance started"}}

          "not_running" ->
            {:ok, _updated_instance} = Instances.restart_instance(instance, account_id)
            {:ok, %{resp: "Instance restarted"}}
        end
      else
        nil -> {:error, %{reason: "not_found"}}
        {:error, error} -> {:error, %{reason: error}}
        _error -> {:error, %{reason: "general_error"}}
      end

    {:reply, resp, socket}
  end

  def handle_in("read_conv", %{"cid" => cid}, socket) do
    "portal:profile:" <> profile_id = socket.topic
    pid = String.to_integer(profile_id)
    {:ok, last_seen} = Portal.MessengerController.update_last_seen(cid, pid)

    {:reply, {:ok, %{last_seen: last_seen}}, socket}
  end

  def handle_info(_, socket),
    do: {:noreply, socket}

  def broadcast_change(channel, payload) do
    Portal.Endpoint.broadcast(channel, "broadcast", payload)
  end
end
