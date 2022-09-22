defmodule Portal.InstanceController do
  @moduledoc """
  The Instance controller.

  API:

  Creates an Instance:
      POST /instances, body: %{instance: instances_params, scenario_id: scenario_id}
  Get a single Instance:
      GET /instances/:iid
  Update an Instance:
      PUT /instances/:iid
  Delete an Instance:
      DELETE /instances/:iid
  Publish an Instance (to make it visible):
      PUT /instances/:iid/publish
  Start or restart an Instance, creates the supervisor and changes the state of the Registrations to `playing`:
      PUT /instances/:iid/start
  Pause an Instance, pauses the supervisor:
      PUT /instances/:iid/pause
  Resume an Instance, starts again the supervisor:
      PUT /instances/:iid/resume
  Finish an Instance, kills the supervisor if the previous instance's state was `running`:
      PUT /instances/:iid/finish
  Export replay (not verified):
      GET /instances/:iid/export-replay
  """
  use Portal, :controller

  alias RC.Instances

  require Logger

  action_fallback(Portal.FallbackController)

  def index(conn, params) do
    aid =
      if conn.private.guardian_default_resource.role == :admin,
        do: nil,
        else: conn.private.guardian_default_resource.id

    case Instances.list_instances(params, :count_registrations, aid) do
      {:ok, instances} ->
        conn
        |> Scrivener.Headers.paginate(instances)
        |> render("index.json", instances: instances)

      error ->
        error
    end
  end

  def publish(conn, %{"iid" => iid}) do
    aid = conn.private.guardian_default_resource.id

    with instance <- Instances.get_instance(iid),
         "created" = instance.state,
         {:ok, _updated_instance} <- Instances.publish_instance(instance, aid) do
      conn
      |> put_status(:ok)
      |> json(%{message: :instance_published})
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  def start(conn, %{"iid" => iid}) do
    aid = conn.private.guardian_default_resource.id

    with instance when not is_nil(instance) <- Instances.get_instance_with_registration(iid),
         state when state in ["open", "not_running"] <- instance.state,
         {:ok, :instantiated} <- Instance.Manager.create_from_model(instance, nil),
         {:ok, :started, _} <- Instance.Manager.call(instance.id, :start) do
      case state do
        # instance hasn't ever been started
        "open" ->
          {:ok, %{registrations_errors: registrations_errors_count}} = Instances.start_instance(instance, aid)

          conn
          |> put_status(:ok)
          |> json(%{message: :instance_started, registrations_errors: registrations_errors_count})

        "not_running" ->
          {:ok, _updated_instance} = Instances.restart_instance(instance, aid)

          conn
          |> put_status(:ok)
          |> json(%{message: :instance_restarted})
      end
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  def restart(conn, %{"iid" => _iid} = params) do
    start(conn, params)
  end

  def finish(conn, %{"iid" => iid}) do
    aid = conn.private.guardian_default_resource.id

    with instance <- Instances.get_instance(iid),
         state when state in ["running", "not_running", "paused"] <- instance.state do
      message =
        if state in ["running", "paused"] do
          case Instance.Manager.destroy(instance.id) do
            {:ok, _} ->
              :instance_killed_and_finished

            {:error, reason} ->
              Logger.error("#{reason}")
              :instance_finished_with_errors
          end
        else
          :instance_finished
        end

      {:ok, instance} = Instances.close_instance(instance)
      {:ok, _updated_instance} = Instances.finish_instance(instance, aid)

      conn
      |> put_status(:ok)
      |> json(%{message: message})
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  def pause(conn, %{"iid" => iid}) do
    aid = conn.private.guardian_default_resource.id

    with instance <- Instances.get_instance(iid),
         "running" = instance.state,
         {:ok, :stopped, _} <- Instance.Manager.call(instance.id, :stop),
         {:ok, _updated_instance} <- Instances.pause_instance(instance, aid) do
      conn
      |> put_status(:ok)
      |> json(%{message: :instance_paused})
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  def resume(conn, %{"iid" => iid}) do
    aid = conn.private.guardian_default_resource.id

    with instance <- Instances.get_instance(iid),
         "paused" = instance.state,
         {:ok, :started, _} <- Instance.Manager.call(instance.id, :start),
         {:ok, _updated_instance} <- Instances.resume_instance(instance, aid) do
      conn
      |> put_status(:ok)
      |> json(%{message: :instance_resumed})
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  def create(conn, %{"instance" => instance_params, "scenario_id" => scenario_id}) do
    aid = conn.private.guardian_default_resource.id

    with scenario when not is_nil(scenario) <- RC.Scenarios.get_scenario(scenario_id),
         {:ok, %{instance: instance}} <- Instances.create_instance(instance_params, scenario, aid) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.instance_path(conn, :show, instance))
      |> render("show.json", instance: instance)
    else
      nil ->
        conn
        |> put_status(404)
        |> json(%{message: :scenario_not_found})

      error ->
        error
    end
  end

  def show(conn, %{"iid" => iid}) do
    case Instances.get_instance(iid) do
      nil -> {:error, :not_found}
      instance -> render(conn, "show.json", instance: instance)
    end
  end

  def update(conn, %{"iid" => iid, "instance" => instance_params}) do
    case Instances.get_instance(iid) do
      nil ->
        {:error, :not_found}

      instance ->
        case Instances.update_instance(instance, instance_params) do
          {:ok, instance} -> render(conn, "show.json", instance: instance)
          error -> error
        end
    end
  end

  def delete(conn, %{"iid" => iid}) do
    instance = Instances.get_instance(iid)

    cond do
      instance == nil ->
        {:error, :not_found}

      instance.state in ["created", "open", "not_running", "ended"] ->
        with {:ok, %Instances.Instance{}} <- Instances.delete_instance(instance) do
          send_resp(conn, :no_content, "")
        end

      true ->
        conn
        |> put_status(403)
        |> json(%{message: :bad_instance_state_for_delete})
    end
  end
end
