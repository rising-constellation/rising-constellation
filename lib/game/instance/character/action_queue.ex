defmodule Instance.Character.ActionQueue do
  use TypedStruct

  alias Instance.Character.Action
  alias Instance.Character.ActionQueue

  require Logger

  def jason(), do: []

  typedstruct enforce: true do
    field(:virtual_position, integer() | nil)
    field(:queue, %Queue{})
  end

  def new() do
    %ActionQueue{
      virtual_position: nil,
      queue: Queue.new()
    }
  end

  def set_virtual_position(%ActionQueue{} = state, virtual_position) do
    %{state | virtual_position: virtual_position}
  end

  def add(%ActionQueue{} = state, action, target) do
    add(%{state | virtual_position: target}, action)
  end

  def add(%ActionQueue{} = state, action) do
    %{state | queue: Queue.insert(state.queue, Action.new(action))}
  end

  def set_virtual_position_and_clear(%ActionQueue{} = state) do
    if ActionQueue.empty?(state) do
      state
    else
      {%Action{} = action, _queue} = Queue.pop(state.queue)

      ActionQueue.new()
      |> set_virtual_position(action.data["target"])
    end
  end

  @doc "replaces the first item of the queue with a new item"
  def replace_front(%ActionQueue{queue: queue} = state, item) do
    {_discarded_action, queue} = Queue.pop(queue)
    %{state | queue: Queue.insert_front(queue, item)}
  end

  @doc "replaces queue content with `new_items` and reset virtual_position"
  def replace_queue([]),
    do: ActionQueue.new()

  def replace_queue(new_items) do
    last_item = List.last(new_items)

    queue =
      ActionQueue.new()
      |> set_virtual_position(last_item.data["target"])

    %{queue | queue: Queue.new(new_items)}
  end

  def skip_initial_lock(nil), do: nil

  def skip_initial_lock(%ActionQueue{} = state) do
    case Queue.pop(state.queue) do
      {%Action{type: :locked}, queue} ->
        %{state | queue: queue}

      _ ->
        state
    end
  end

  @doc "(unlocks if necessary, then) removes current action"
  def abort_action(%ActionQueue{} = state) do
    case Queue.pop(state.queue) do
      {nil, queue} -> %{state | queue: queue}
      {%Action{type: :locked}, queue} -> abort_action(%{state | queue: queue})
      {%Action{}, queue} -> %{state | queue: queue}
    end
  end

  def clear_after(%ActionQueue{} = state, index) do
    Queue.to_list(state.queue)
    |> Enum.take(index)
    |> ActionQueue.replace_queue()
  end

  def lock(%ActionQueue{} = state) do
    queue = Queue.insert_front(state.queue, Action.new({:locked, %{lock: true}, 100}))
    %{state | queue: queue}
  end

  def unlock(%ActionQueue{} = state) do
    {%Action{type: :locked}, queue} = Queue.pop(state.queue)
    %{state | queue: queue}
  end

  def process_next_action(%ActionQueue{} = state, time_since_last_tick, cumulated_pauses) do
    {action, popped_queue} = Queue.pop(state.queue)

    cond do
      is_nil(action) ->
        :empty

      action.type == :locked ->
        :queue_locked

      is_nil(action.started_at) ->
        updated_action = Action.start(action, cumulated_pauses)
        {:to_start, action, replace_front(state, updated_action)}

      is_number(action.remaining_time) ->
        case Action.compute_remaining_time(action, time_since_last_tick, cumulated_pauses) do
          {:start, updated_action} ->
            {:to_start, updated_action, replace_front(state, updated_action)}

          {:unfinished, updated_action} ->
            {:ongoing, updated_action, replace_front(state, updated_action)}

          {:finished, _finished_x_ms_ago} ->
            {:to_finish, action, %{state | queue: popped_queue}}
        end

      true ->
        Logger.error("cannot process action #{inspect(action)}")
        :error
    end
  end

  def get_next_action_remaining_time(state) do
    action = Queue.peek(state.queue)

    cond do
      is_nil(action) ->
        :never

      is_number(action.remaining_time) ->
        action.remaining_time

      true ->
        0.1
    end
  end

  def empty?(state) do
    Queue.empty?(state.queue)
  end

  def map(state, fun) when is_function(fun, 1) do
    %{state | queue: Queue.map(state.queue, fun)}
  end
end
