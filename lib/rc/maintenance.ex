defmodule RC.Maintenance do
  @moduledoc """
  The Maintenance context.
  """

  import Ecto.Query, warn: false

  alias Portal.Config
  alias Portal.Controllers.PortalChannel
  alias RC.Maintenance
  alias RC.Repo

  @doc """
  Write flag to DB and update cache (cache is warmed up from DB at startup)
  """
  def set_flag(flag, account_id) do
    Config.update_key(:maintenance_flag, flag)

    PortalChannel.broadcast_change("portal:user:*", %{maintenance_flag: flag})

    Maintenance.Log.changeset(
      %Maintenance.Log{
        min_client_version: get_version()
      },
      %{flag: flag, account_id: account_id}
    )
    |> Repo.insert()
  end

  @doc """
  Write version to DB and update cache (cache is warmed up from DB at startup)
  """
  def set_version(version, account_id) do
    Config.update_key(:min_client_version, version)

    PortalChannel.broadcast_change("portal:user:*", %{min_client_version: version})

    Maintenance.Log.changeset(
      %Maintenance.Log{
        flag: get_flag()
      },
      %{min_client_version: version, account_id: account_id}
    )
    |> Repo.insert()
  end

  @doc """
  Get flag from cache, fallback to DB
  """
  def get_flag() do
    case Config.fetch_key(:maintenance_flag) do
      :error ->
        get_flag_from_db()

      flag ->
        flag
    end
  end

  @doc """
  Get version from cache, fallback to DB
  """
  def get_version() do
    case Config.fetch_key(:min_client_version) do
      :error ->
        get_version_from_db()

      version ->
        version
    end
  end

  def get_latest() do
    latest =
      from(l in Maintenance.Log, order_by: [desc: :id], limit: 1)
      |> Repo.one()

    case latest do
      nil -> %Maintenance.Log{flag: false, min_client_version: "0.0.0"}
      latest -> latest
    end
  end

  def get_flag_from_db() do
    case get_latest() do
      nil -> false
      %Maintenance.Log{flag: flag} -> flag
    end
  end

  def get_version_from_db() do
    case get_latest() do
      nil -> "0.0.0"
      %Maintenance.Log{min_client_version: min_client_version} -> min_client_version
    end
  end
end
