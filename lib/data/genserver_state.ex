defmodule Data.GenServerState do
  @doc """
  Save a process state somewhere (at the moment: as Registry metadata)
  """
  def save(name_tuple, state, module) do
    Horde.Registry.put_meta(Game.Registry, save_tuple(name_tuple), %{state: state, module: module})

    state
  end

  @doc """
  Retrieve state for a process
  """
  def retrieve(name_tuple) do
    Horde.Registry.meta(Game.Registry, save_tuple(name_tuple))
  end

  @doc """
  Retrieve state for a process
  """
  def retrieve_delete(name_tuple) do
    retrieved = retrieve(name_tuple)
    delete(name_tuple)
    retrieved
  end

  @doc """
  Clear saved state for a process
  """
  def delete(name_tuple) do
    Horde.Registry.delete_meta(Game.Registry, save_tuple(name_tuple))
  end

  @doc """
  Clear all saved state for an instance
  """
  def clear(instance_id) do
    list(instance_id)
    |> Enum.each(&delete/1)
  end

  @doc """
  Clear all saved state for an instance after n seconds
  """
  def wait_and_clear(instance_id) do
    Task.start(fn ->
      Process.sleep(5_000)
      clear(instance_id)
    end)
  end

  @doc """
  List all saved state for an instance
  """
  def list(instance_id) do
    DeltaCrdt.read(Game.Registry.Crdt)
    |> Enum.reduce([], fn {{k, name_tuple}, _v}, acc ->
      case k do
        :registry ->
          case name_tuple do
            {{^instance_id, _, _} = name_tuple, :saved_state} -> [name_tuple | acc]
            {{^instance_id, _} = name_tuple, :saved_state} -> [name_tuple | acc]
            _ -> acc
          end

        _ ->
          acc
      end
    end)
  end

  defp save_tuple(name_tuple) do
    {name_tuple, :saved_state}
  end
end
