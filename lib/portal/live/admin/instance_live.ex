defmodule Portal.InstanceLive do
  use Portal, :admin_live_view

  require Logger

  alias Instance.Manager
  alias RC.Instances
  alias RC.Instances.Instance
  alias RC.InstanceSnapshots
  alias RC.Instances.InstanceSnapshot
  alias RC.Instances.InstanceStateMachine
  alias RC.Groups
  alias RC.Groups.Group
  alias RC.Accounts

  @impl true
  def mount(_params, session, socket) do
    socket =
      socket
      |> assign(:current_user, RC.Guardian.resource_from_session(session))
      |> assign(conn: socket)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _, socket) do
    instance = Instances.get_instance(Map.get(params, "iid"))

    if instance != nil do
      account = RC.Accounts.get_account(instance.account_id)
      snapshots = InstanceSnapshots.list(instance.id)
      states = Instances.get_instance_states(instance.id)

      {:noreply, assign(socket, instance: instance, snapshots: snapshots, states: states, account: account)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("stop_supervisor", _, socket) do
    instance = socket.assigns.instance

    with true <- instance.supervisor_status != :not_instantiated,
         {:ok, _status} <- Manager.destroy(instance.id) do
      instance
      |> Map.put(:account_id, socket.assigns.current_user.id)
      |> Machinery.transition_to(InstanceStateMachine, "not_running")

      instance = Instances.get_instance(instance.id)
      states = Instances.get_instance_states(instance.id)

      {:noreply, assign(socket, instance: instance, states: states)}
    else
      false ->
        Logger.error("instance_not_instantiated")
        {:noreply, socket}

      {:error, err} ->
        Logger.error(inspect(err))
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("fix_agents", _, socket) do
    instance = socket.assigns.instance

    with true <- instance.supervisor_status != :not_instantiated,
         fixed_count <- Manager.fix_agents(instance.id) do
      {:noreply, put_flash(socket, :info, "Correction de #{fixed_count} agent")}
    else
      _ ->
        {:noreply, put_flash(socket, :info, "Problème lors de la correction des agents")}
    end
  end

  @impl true
  def handle_event("bind_group", %{"group" => group}, socket) do
    with %Instance{} = instance <- Instances.get_instance(socket.assigns.instance.id),
         %Group{} = group <- Groups.get_group(group["id"]) do
      Groups.insert_instances(group, [instance.id])

      instance = Instances.get_instance(instance.id)
      {:noreply, assign(socket, instance: instance)}
    else
      _ -> {:noreply, socket}
    end
  end

  @impl true
  def handle_event("unbind_group", %{"gid" => gid}, socket) do
    with %Instance{} = instance <- Instances.get_instance(socket.assigns.instance.id),
         %Group{} = group <- Groups.get_group(gid) do
      Groups.remove_instance(group, instance.id)

      instance = Instances.get_instance(instance.id)
      {:noreply, assign(socket, instance: instance)}
    else
      _ -> {:noreply, socket}
    end
  end

  @impl true
  def handle_event("create_snapshot", _, %{assigns: %{instance: %{state: "running"}}} = socket) do
    instance_id = socket.assigns.instance.id

    with {:ok, :stopped, _} <- Manager.call(instance_id, :stop),
         {:ok, _snapshot} <- Manager.call(instance_id, :make_snapshot),
         {:ok, :started, _} <- Manager.call(instance_id, :start) do
      snapshots = InstanceSnapshots.list(instance_id)

      socket =
        socket
        |> put_flash(:info, "Done")
        |> assign(snapshots: snapshots)

      {:noreply, socket}
    else
      {:error, err} ->
        {:noreply, put_flash(socket, :error, inspect(err))}
    end
  end

  @impl true
  def handle_event("create_snapshot", _, %{assigns: %{instance: %{state: "paused"}}} = socket) do
    instance_id = socket.assigns.instance.id

    case Manager.call(instance_id, :make_snapshot) do
      {:ok, _snapshot} ->
        snapshots = InstanceSnapshots.list(instance_id)

        socket =
          socket
          |> put_flash(:info, "Done")
          |> assign(snapshots: snapshots)

        {:noreply, socket}

      {:error, err} ->
        {:noreply, put_flash(socket, :error, inspect(err))}
    end
  end

  @impl true
  def handle_event("create_snapshot", _, socket) do
    {:noreply,
     put_flash(socket, :error, "Wrong instance state: #{socket.assigns.instance.state} instead of running/paused")}
  end

  @impl true
  def handle_event("restore_snapshot", %{"sid" => sid}, socket) do
    instance_id = socket.assigns.instance.id

    with %InstanceSnapshot{} = snapshot <- InstanceSnapshots.get(sid),
         {:ok, snapshot} <- Util.Storage.load(snapshot.name),
         {:ok, :instantiated} <- Manager.create_from_snapshot(instance_id, snapshot),
         {:ok, _} <-
           Instances.create_instance_state(%{instance_id: instance_id, state: "paused"}, socket.assigns.current_user.id) do
      instance = Instances.get_instance(instance_id)
      {:noreply, assign(socket, instance: instance)}
    else
      err ->
        Logger.error(inspect(err))
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("delete_snapshot", %{"sid" => sid}, socket) do
    with %InstanceSnapshot{} = snapshot <- InstanceSnapshots.get(sid),
         :ok <- Util.Storage.delete(snapshot.name),
         {:ok, %InstanceSnapshot{}} <- InstanceSnapshots.delete(snapshot) do
      snapshots = InstanceSnapshots.list(socket.assigns.instance.id)
      {:noreply, assign(socket, snapshots: snapshots)}
    else
      _ -> {:noreply, socket}
    end
  end

  @impl true
  def handle_event("get_profiles", %{"fid" => fid}, socket) do
    profiles = Accounts.list_profiles_by_faction(fid)

    if profiles != [],
      do: {:noreply, assign(socket, profiles: profiles)},
      else: {:noreply, socket}
  end
end
