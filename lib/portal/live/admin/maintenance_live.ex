defmodule Portal.MaintenanceLive do
  use Portal, :admin_live_view
  require Logger
  alias RC.Instances

  @impl true
  def mount(_params, session, socket) do
    socket =
      socket
      |> assign(:current_user, RC.Guardian.resource_from_session(session))
      |> assign(conn: socket)

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _, socket) do
    socket = fetch_and_load(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("maintenance_toggle", params, socket) do
    flag =
      case params do
        %{"maintenance_flag" => "true"} -> true
        _ -> false
      end

    RC.Maintenance.set_flag(flag, socket.assigns.current_user.id)

    {:noreply, assign(socket, maintenance_flag: flag)}
  end

  @impl true
  def handle_event("restore", _params, socket) do
    instances = list_instances()
    state = guess_state(instances)

    account_id = socket.assigns.current_user.id
    pid = self()

    if state == :restore do
      Task.start(fn ->
        send(pid, :working)

        instances
        |> Task.async_stream(
          fn instance ->
            send(pid, {"restoring", instance.id})
            Instances.restore_instance(instance, account_id)
          end,
          timeout: 120_000,
          ordered: true,
          on_timeout: :kill_task
        )
        |> Enum.reduce(instances, fn task_result, [%{id: id} | tail] ->
          with {:ok, save_result} <- task_result,
               {:ok, _} <- save_result do
            send(pid, {"restored", id})
          else
            {:error, reason} ->
              Logger.error("restore failed #{inspect(reason)}")
              send(pid, {"restore_failed", id})

            {:exit, reason} ->
              Logger.error("restore task failed #{inspect(reason)}")
              send(pid, {"restore_task_failed", id})
          end

          tail
        end)

        send(pid, :done)
      end)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("save", _params, socket) do
    instances = list_instances()
    state = guess_state(instances)

    account_id = socket.assigns.current_user.id
    pid = self()

    if state == :save do
      Task.start(fn ->
        send(pid, :working)

        instances
        |> Task.async_stream(
          fn instance ->
            send(pid, {"saving", instance.id})
            Instances.maintenance_instance(instance, account_id)
          end,
          timeout: 120_000,
          ordered: true,
          on_timeout: :kill_task
        )
        |> Enum.reduce(instances, fn task_result, [%{id: id} | tail] ->
          with {:ok, save_result} <- task_result,
               {:ok, _} <- save_result do
            send(pid, {"saved", id})
          else
            {:error, reason} ->
              Logger.error("save failed #{inspect(reason)}")
              send(pid, {"save_failed", id})

            {:exit, reason} ->
              Logger.error("save task failed #{inspect(reason)}")
              send(pid, {"save_task_failed", id})
          end

          tail
        end)

        send(pid, :done)
      end)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("refresh", _params, socket) do
    {:noreply, fetch_and_load(socket)}
  end

  @impl true
  def handle_info({action, instance_id}, socket) when is_binary(action) do
    actions = Map.update(socket.assigns.actions, instance_id, "", fn _ -> action end)

    {:noreply, assign(socket, actions: actions)}
  end

  @impl true
  def handle_info(:working, socket) do
    {:noreply, assign(socket, working: true)}
  end

  @impl true
  def handle_info(:done, socket) do
    {:noreply, assign(socket, working: false, done: true)}
  end

  defp fetch_and_load(socket) do
    instances = list_instances()
    state = guess_state(instances)

    actions =
      Enum.reduce(instances, %{}, fn %{id: id}, acc ->
        Map.put(acc, id, Atom.to_string(state))
      end)

    assign(socket,
      instances: instances,
      state: state,
      actions: actions,
      working: false,
      done: false,
      maintenance_flag: RC.Maintenance.get_flag()
    )
  end

  defp list_instances do
    in_maintenance = Instances.list_instances_with_state("maintenance")

    if Enum.empty?(in_maintenance) do
      Instances.list_instances_with_state(["running", "paused"])
      |> Enum.map(&Instances.put_instance_supervisor_status/1)
      |> Enum.filter(fn instance -> instance.supervisor_status in [:running, :instantiated] end)
    else
      in_maintenance
      |> Enum.map(&Instances.put_instance_supervisor_status/1)
      |> Enum.filter(fn instance -> instance.supervisor_status == :not_instantiated end)
    end
  end

  defp guess_state(instances) do
    if not Enum.empty?(instances) and hd(instances).state === "maintenance" do
      :restore
    else
      :save
    end
  end
end
