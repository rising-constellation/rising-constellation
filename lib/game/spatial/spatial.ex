defmodule Spatial do
  @moduledoc """
  Spatial queries and utils for visibility, based on DDRT
  """
  alias Instance.Character.Action
  alias Instance.Character.Character
  alias Spatial.Disk
  alias Spatial.Position

  def update(%Character{status: :on_board, action_status: :moving} = character) do
    bbox = fetch_bbox(character)

    if is_nil(bbox) do
      delete(character)
    else
      s_upsert(get_name(character), bbox, character.instance_id)
    end
  end

  def update(%Character{} = character),
    do: delete(character)

  def update(%Character{status: :on_board, action_status: :moving} = character, %Action{} = action) do
    bbox = fetch_jump_bbox(action)

    s_upsert(get_name(character), bbox, character.instance_id)
  end

  def update(%Character{} = character, %Action{}),
    do: delete(character)

  def delete(%Character{} = character) do
    s_delete(get_name(character), character.instance_id)
  end

  def delete(name, instance_id) when is_binary(name) and is_integer(instance_id) do
    s_delete(name, instance_id)
  end

  def nearby(%Disk{x: x, y: y, radius: radius} = disk, instance_id) do
    weight = 2.5
    [x_min, x_max, y_min, y_max] = [x - radius * weight, x + radius * weight, y - radius * weight, y + radius * weight]

    with {:ok, objects} <- s_query([{x_min, x_max}, {y_min, y_max}], instance_id),
         false <- Enum.empty?(objects) do
      Enum.map(objects, fn name -> {disk, name} end)
    else
      _ -> []
    end
  end

  def load(leaves, instance_id) do
    s_insert(leaves, instance_id)
  end

  def dump(instance_id) do
    DDRT.tree(get_name(instance_id)).map
    |> Enum.reduce([], fn {key, val}, acc ->
      case val do
        {:leaf, _, bbox} -> [{key, bbox} | acc]
        _ -> acc
      end
    end)
  end

  ## private functions - ddrt utils

  defp s_insert(leaves, instance_id) when is_list(leaves) do
    DDRT.insert(leaves, get_name(instance_id))
  end

  defp s_insert(name, bbox, instance_id) when is_list(bbox) do
    DDRT.insert({name, bbox}, get_name(instance_id))
  end

  defp s_query(bbox, instance_id) do
    DDRT.query(bbox, get_name(instance_id))
  end

  def s_upsert(name, nil, instance_id), do: s_delete(name, instance_id)

  def s_upsert(name, bbox, instance_id) do
    {:ok, ddrt} = DDRT.update(name, bbox, get_name(instance_id))

    if Map.has_key?(ddrt.map, name) do
      {:ok, ddrt}
    else
      s_insert(name, bbox, instance_id)
    end
  end

  # defp s_update(name, nil, instance_id), do: s_delete(name, instance_id)

  # defp s_update(name, bbox, instance_id) do
  #   DDRT.update(name, bbox, get_name(instance_id))
  # end

  defp s_delete(names, instance_id) when is_list(names) do
    DDRT.delete(names, get_name(instance_id))
  end

  defp s_delete(name, instance_id) when is_binary(name) or is_atom(name) do
    s_delete([name], instance_id)
  end

  defp fetch_bbox(%Character{} = character) do
    {:ok, pos} = call(character.instance_id, :character, character.id, :get_position)
    bbox_from_position(pos)
  end

  defp fetch_jump_bbox(%Action{} = action) do
    bbox_from_position(action.data["source_position"], action.data["target_position"])
  end

  @doc """

  ### Bounding-Box Format

      [{x_min,x_max}, {y_min,y_max}]

      Example:                               & & & & & y_max & & & & &
        A unit at pos x: 10, y: -12 ,        &                       &
        with x_size: 1 and y_size: 2         &                       &
        would be represented with            &          pos          &
        the following bounding box         x_min       (x,y)       x_max
        [{9.5,10.5},{-13,-11}]               &                       &
                                             &                       &
                                             &                       &
                                             & & & & & y_min & & & & &
  ## Example
      iex> bbox_from_position(nil)
      nil
      iex> bbox_from_position(%Position{x: 10, y: 100})
      [{10, 10.5}, {100, 100.5}]
      iex> bbox_from_position(%Position{x: 10, y: 100}, nil)
      [{10, 10.5}, {100, 100.5}]
      iex> bbox_from_position(nil, %Position{x: 200, y: 20})
      [{200, 200.5}, {20, 20.5}]
      iex> bbox_from_position(%Position{x: 10, y: 100}, %Position{x: 200, y: 20})
      [{10, 200}, {20, 100}]
  """
  def bbox_from_position(nil), do: nil

  def bbox_from_position(%Position{x: x1, y: y1}) do
    [{x1, x1}, {y1, y1}] |> bbox_fix()
  end

  def bbox_from_position(%Position{} = pos1, nil), do: bbox_from_position(pos1)
  def bbox_from_position(nil, %Position{} = pos2), do: bbox_from_position(pos2)

  def bbox_from_position(%Position{x: x1, y: y1}, %Position{x: x2, y: y2}) do
    [{Kernel.min(x1, x2), Kernel.max(x1, x2)}, {Kernel.min(y1, y2), Kernel.max(y1, y2)}] |> bbox_fix()
  end

  # see #445
  def bbox_fix([{x1, x1}, {y1, y1}]), do: [{x1, x1 + 0.5}, {y1, y1 + 0.5}]
  def bbox_fix([{x1, x1}, {y1, y2}]), do: [{x1, x1 + 0.5}, {y1, y2}]
  def bbox_fix([{x1, x2}, {y1, y1}]), do: [{x1, x2}, {y1, y1 + 0.5}]
  def bbox_fix(bbox), do: bbox

  ## private functions - utils
  def get_name(%Character{} = character), do: "c-#{character.id}"
  def get_name(instance_id) when is_integer(instance_id) or is_binary(instance_id), do: :"#{instance_id}"

  defp call(instance_id, type, agent_id, action) do
    case Game.call(instance_id, type, agent_id, action) do
      {:ok, val} -> {:ok, val}
      _ -> {:ok, nil}
    end
  end
end
