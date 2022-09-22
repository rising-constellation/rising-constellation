defmodule Portal.NodesLive do
  use Portal, :admin_live_view

  @impl true
  def handle_params(_params, _, socket) do
    {:noreply, assign(socket, nodes: nodes())}
  end

  @impl true
  def handle_event("remove", %{"name" => name}, socket) do
    valid_node =
      nodes()
      |> Enum.map(fn %{name: name} -> Atom.to_string(name) end)
      |> Enum.member?(name)

    case valid_node do
      true ->
        node_name = String.to_atom(name)
        :rpc.call(node_name, :init, :stop, [])

        {:noreply, assign(socket, nodes: nodes())}

      false ->
        {:noreply, assign(socket, nodes: nodes())}
    end
  end

  @impl true
  def handle_event("garbage-collect", %{"name" => name}, socket) do
    node_name = String.to_atom(name)
    Node.spawn(node_name, fn -> Process.list() |> Enum.each(&:erlang.garbage_collect/1) end)
    {:noreply, put_flash(socket, :info, "C'est tout bon")}
  end

  defp nodes() do
    [Node.self() | Node.list()]
    |> Enum.with_index(1)
    |> Enum.map(fn {name, id} ->
      revision = :rpc.call(name, Application, :get_env, [:rc, :revision])

      %{id: id, name: name, revision: revision}
    end)
  end
end
