defmodule Portal.RegistrationController do
  @moduledoc """
  The Regitration controller.

  API:

  Creates a Registration in an Instance and Faction:
      POST /registrations/profile/:pid, body: %{instance_id: iid, faction_id: fid}
  Cancel a Registration:
      PUT /registrations/profile/:pid/cancel, body: %{faction_id: fid}
  Kill a player, updates the Registration state
      PUT /registrations/profile/:pid/kill, body: %{faction_id: fid}
  Resign a player, updates the Registration state
      PUT /registrations/profile/:pid/resign, body: %{faction_id: fid}

  """
  use Portal, :controller

  alias Ecto.Multi
  alias RC.Accounts
  alias RC.Instances
  alias RC.Instances.RegistrationStateMachine
  alias RC.Registrations
  alias RC.Repo

  require Logger

  def index_by_instance(conn, %{"iid" => instance_id}) do
    with instance when not is_nil(instance) <- Instances.get_instance(instance_id),
         registrations <- Registrations.list(instance_id) do
      conn
      |> render("index.json", registrations: registrations)
    else
      nil ->
        conn
        |> put_status(404)
        |> json(%{message: :instance_not_found})
    end
  end

  def join(conn, %{"pid" => pid, "instance_id" => iid, "faction_id" => fid}) do
    aid = conn.private.guardian_default_resource.id

    with instance when not is_nil(instance) <- Instances.get_instance(iid),
         faction when not is_nil(faction) <- Instances.get_faction(fid),
         profile when not is_nil(profile) <- Accounts.get_profile(pid),
         account when not is_nil(account) <- Accounts.get_account(profile.account_id),
         true <- not account.is_free or account.money >= 500 or :not_enough_money,
         true <- not Registrations.registered?(%{instance_id: instance.id, account_id: aid}),
         true <- Enum.member?(["open", "running"], instance.state) or :registrations_not_open,
         true <- Registrations.count_by_faction(fid) < faction.capacity or :instance_full do
      Enum.each(RC.Messenger.list_conversations_by_faction(iid, fid), fn c ->
        {:ok, _conversation_member} =
          RC.Messenger.create_conversation_member(%{
            conversation_id: c.id,
            profile_id: pid,
            last_seen: DateTime.utc_now(),
            is_admin: false
          })
      end)

      cond do
        instance.state == "open" ->
          register_profile(conn, profile, faction, instance, "joined")

        instance.state == "running" and instance.registration_type == :late_registration ->
          register_profile(conn, profile, faction, instance, "playing")

        true ->
          conn
          |> put_status(403)
          |> json(%{message: :instance_in_pre_registration_mode})
      end
    else
      :registrations_not_open ->
        conn
        |> put_status(400)
        |> json(%{message: :registrations_not_open})

      :instance_full ->
        conn
        |> put_status(400)
        |> json(%{message: :instance_full})

      :not_enough_money ->
        conn
        |> put_status(400)
        |> json(%{message: :not_enough_money})

      nil ->
        conn
        |> put_status(404)
        |> json(%{message: :instance_or_faction_or_profile_not_found})

      err ->
        Logger.error(err)

        conn
        |> put_status(:conflict)
        |> json(%{message: :already_registered})
    end
  end

  def unjoin(conn, %{"faction_id" => fid, "pid" => pid}) do
    with profile <- Accounts.get_profile(pid),
         true <- not is_nil(profile) or :profile_not_found,
         registration <- Registrations.get(%{faction_id: fid, profile_id: pid}),
         true <- not is_nil(registration) or :registration_not_found,
         account when not is_nil(account) <- Accounts.get_account(profile.account_id),
         {:ok, _} <-
           Multi.new()
           |> Multi.delete("delete_registration", registration)
           |> Repo.transaction() do
      if account.is_free do
        RC.Accounts.update_account_money(Multi.new(), account, 500, "unjoin_instance")
        |> Repo.transaction()
      end

      conn
      |> put_status(:ok)
      |> json(%{message: "profile_unregistered"})
    else
      :registration_not_found ->
        conn
        |> put_status(404)
        |> json(%{message: :registration_not_found})

      :profile_not_found ->
        conn
        |> put_status(404)
        |> json(%{message: :profile_not_found})

      error ->
        error
    end
  end

  def kill(conn, %{"faction_id" => fid, "pid" => pid}) do
    change_registration_state(conn, fid, pid, "dead", :profile_killed)
  end

  def resign(conn, %{"faction_id" => fid, "pid" => pid}) do
    change_registration_state(conn, fid, pid, "resigned", :profile_resigned)
  end

  defp change_registration_state(conn, fid, pid, state, returned_atom) when state in ["resigned", "dead"] do
    with registration when not is_nil(registration) <- Registrations.get(%{faction_id: fid, profile_id: pid}),
         {:ok, _updated_registration} <- Machinery.transition_to(registration, RegistrationStateMachine, state) do
      conn
      |> put_status(:ok)
      |> json(%{message: returned_atom})
    else
      error -> error
    end
  end

  defp register_profile(conn, profile, faction, instance, registration_initial_state) do
    case Registrations.register_profile(faction, profile, registration_initial_state) do
      {:ok, %{registration: registration, registration_state: _registration_state}} ->
        if Instance.Manager.created?(instance.id) do
          Instance.Manager.call(instance.id, {:add_player, faction, profile, registration.id})
        end

        conn
        |> put_status(:ok)
        |> json(%{message: :registered})

      {:error, failed_operation, failed_value, _changes_so_far} ->
        Logger.info("#{inspect(failed_operation)}, failed value: #{inspect(failed_value)}")

        conn
        |> put_status(500)
        |> json(%{message: Repo.format_errors(failed_value)})
    end
  end
end
