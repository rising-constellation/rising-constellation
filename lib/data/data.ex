defmodule Data.Data do
  def insert(instance_id, metadata) do
    game_data = [metadata: metadata, data: Data.Querier.fetch_all(metadata)]
    Horde.Registry.put_meta(Game.Registry, name_tuple(instance_id), game_data)
  end

  def get(instance_id, key) when is_integer(instance_id) do
    {:ok, data} = Horde.Registry.meta(Game.Registry, name_tuple(instance_id))
    data |> Keyword.fetch!(key)
  end

  def get(:fast_prod, key), do: get_without_cache(key, speed: :fast, mode: :prod)

  defp get_without_cache(key, metadata) do
    [metadata: metadata, data: Data.Querier.fetch_all(metadata)]
    |> Keyword.fetch!(key)
  end

  def clear(instance_id) do
    Horde.Registry.unregister(Game.Registry, name_tuple(instance_id))
  end

  def export(instance_id) do
    {:ok, data} = Horde.Registry.meta(Game.Registry, name_tuple(instance_id))
    data
  end

  defp name_tuple(instance_id), do: {instance_id, :game_data}
end
