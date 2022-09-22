defmodule Portal.Config do
  alias Portal.Controllers.PortalChannel

  @meta_key :portal_config

  def init_config do
    # registry might not have started yet so we'll wait until it's up before anything else
    wait_for_registry()
    # only if it doesn't exist yet as to avoid overwriting from a new node
    if fetch() == :error do
      %{flag: flag, min_client_version: version} = RC.Maintenance.get_latest()
      # Cache config map
      config = %{
        signup_mode: Application.get_env(:rc, :signup_mode),
        login_mode: Application.get_env(:rc, :login_mode),
        maintenance_flag: flag,
        min_client_version: version
      }

      PortalChannel.broadcast_change("portal:user:*", Map.take(config, [:maintenance_flag, :min_client_version]))

      Horde.Registry.put_meta(Game.Registry, @meta_key, config)
    end
  end

  defp wait_for_registry do
    try do
      :ets.lookup(Game.Registry, @meta_key)
      RC.Maintenance.get_latest()
    catch
      :error, :badarg ->
        Process.sleep(250)
        wait_for_registry()
    end
  end

  def fetch do
    Horde.Registry.meta(Game.Registry, @meta_key)
  end

  def fetch_key(key) do
    case fetch() do
      {:ok, config} -> Map.fetch!(config, key)
      :error -> :error
    end
  end

  def update_key(key, value) do
    case fetch() do
      {:ok, config} ->
        new_config = Map.update!(config, key, fn _ -> value end)
        Horde.Registry.put_meta(Game.Registry, @meta_key, new_config)

      :error ->
        :error
    end
  end

  def prepare_signup_mode(mode) do
    try do
      mode = String.to_existing_atom(mode)

      if Enum.member?(signup_modes(), mode),
        do: {:ok, mode},
        else: {:error, :invalid_signup_mode}
    rescue
      ArgumentError ->
        {:error, :invalid_signup_mode}
    end
  end

  def prepare_login_mode(mode) do
    try do
      mode = String.to_existing_atom(mode)

      if Enum.member?(login_modes(), mode),
        do: {:ok, mode},
        else: {:error, :invalid_login_mode}
    rescue
      ArgumentError ->
        {:error, :invalid_login_mode}
    end
  end

  def signup_modes(), do: [:disabled, :manual_validation, :mail_validation]
  def login_modes(), do: [:disabled, :enabled]
end
