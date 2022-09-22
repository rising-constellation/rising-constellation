defmodule Instance.StellarSystem.ProductionQueue do
  use TypedStruct

  alias Instance.StellarSystem

  def jason(), do: []

  typedstruct enforce: true do
    field(:queue, [%StellarSystem.ProductionItem{}] | [])
  end

  def new() do
    %StellarSystem.ProductionQueue{
      queue: Queue.new()
    }
  end

  def queue_item(%{queue: queue}, type, production_data) do
    item = List.last(Queue.to_list(queue))
    id = if item, do: item.id + 1, else: 1

    %{queue: Queue.insert(queue, StellarSystem.ProductionItem.new(type, production_data, id))}
  end

  def unqueue_item(%{queue: queue}, production_id) do
    if Queue.empty?(queue) do
      {:error, :queue_empty}
    else
      item =
        queue
        |> Queue.filter(fn i -> i.id == production_id end)
        |> Queue.to_list()
        |> List.first()

      if item do
        queue = Queue.filter(queue, fn i -> i.id != production_id end)
        {:ok, item, %{queue: queue}}
      else
        {:error, :item_not_found}
      end
    end
  end

  def unqueue_last_item(%{queue: queue}) do
    if Queue.empty?(queue) do
      {:queue_empty, %{queue: queue}}
    else
      {item, queue} = Queue.pop_rear(queue)

      {:ok, item, %{queue: queue}}
    end
  end

  def add_production(%{queue: queue}, production) do
    if Queue.empty?(queue) do
      %{queue: queue}
    else
      {item, queue} = Queue.pop(queue)

      case StellarSystem.ProductionItem.add_production(item, production) do
        {:unfinished, updated_item} ->
          %{queue: Queue.insert_front(queue, updated_item)}

        {:finished, rest} ->
          {%{queue: queue}, rest, item}
      end
    end
  end

  @doc """
  Rejects production items that have target_id AND type
  """
  def reject_items(%{queue: queue}, target_id, type) do
    %{queue: Queue.filter(queue, fn item -> item.target_id != target_id or item.type != type end)}
  end

  def get_next_action_remaining_time(stellar_system) do
    case Queue.peek(stellar_system.queue.queue) do
      nil ->
        :never

      item ->
        if stellar_system.production.value == 0,
          do: 0,
          else: item.remaining_prod / stellar_system.production.value
    end
  end
end
