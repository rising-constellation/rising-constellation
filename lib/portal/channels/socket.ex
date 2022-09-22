defmodule Portal.Socket do
  use Phoenix.Socket

  # Channels
  channel("portal:*", Portal.Controllers.PortalChannel)
  channel("instance:global:*", Portal.Controllers.GlobalChannel)
  channel("instance:faction:*", Portal.Controllers.FactionChannel)
  channel("instance:player:*", Portal.Controllers.PlayerChannel)

  @impl true
  def connect(%{"token" => token}, socket) do
    case Guardian.Phoenix.Socket.authenticate(socket, RC.Guardian, token) do
      {:ok, socket} ->
        %{id: id, role: role} = account_from_socket(socket)

        {:ok, assign(socket, :account, %{id: id, role: role})}

      {:error, _} ->
        :error
    end
  end

  @impl true
  def connect(_params, _socket), do: :error

  @impl true
  def id(_socket), do: nil

  @doc """
  Util function to garbage collect the transport process, use it after processing large messages:
  https://hexdocs.pm/phoenix/Phoenix.Socket.html#module-garbage-collection
  """
  def gc(socket, wait \\ 5_000) do
    Task.start(fn ->
      Process.sleep(wait)
      send(socket.transport_pid, :garbage_collect)
    end)
  end

  defp account_from_socket(socket) do
    %{guardian_default_resource: %RC.Accounts.Account{} = account} = socket.assigns
    %{id: account.id, role: account.role}
  end
end
