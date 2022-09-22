defmodule Queue do
  @moduledoc """
  This module provides (double-ended) FIFO queues in an efficient manner.
  Wrapper around http://erlang.org/doc/man/queue.html
  All operations have an amortized O(1) running time, except length that has O(n).

  Queues are double-ended. The mental picture of a queue is a line of people (items)
  waiting for their turn. The queue front is the end with the item that has waited the longest.
  The queue rear is the end an item enters when it starts to wait.
  If instead using the mental picture of a list, the front is called head and the rear is called tail.

  Entering at the front and exiting at the rear are reverse operations on the queue.
  """
  use TypedStruct

  def jason(), do: []

  typedstruct enforce: true do
    field(:q, [any])
  end

  @doc """
  Creates a new, empty queue

  ## Example
      iex> Queue.new
      %Queue{q: {[], []}}
      iex> Queue.new |> Queue.empty?
      true
  """
  def new() do
    wrap(:queue.new())
  end

  @doc """
  Creates a new queue from a given list

  ## Example
      iex> q = Queue.new([1,2,3,4])
      %Queue{q: {[4], [1, 2, 3]}}
      iex> Queue.length(q)
      4
      iex> Queue.peek(q)
      1
  """
  def new(xs) do
    wrap(:queue.from_list(xs))
  end

  @doc """
  Gets the length of a queue

  ## Example
      iex> Queue.new() |> Queue.length
      0
      iex> Enum.to_list(1..5) |> Queue.new |> Queue.length
      5
      iex> Enum.to_list(1..12) |> Queue.new |> Queue.length
      12
  """
  def length(%Queue{q: q}) do
    :queue.len(q)
  end

  @doc """
  Gets a queue as a List

  ## Example
      iex> Queue.new |> Queue.to_list
      []
      iex> Enum.to_list(1..5) |> Queue.new |> Queue.to_list
      [1, 2, 3, 4, 5]
  """
  def to_list(%Queue{q: q}) do
    :queue.to_list(q)
  end

  @doc """
  Adds an item to the front of the queue

  ## Example
      iex> Queue.new |> Queue.insert_front(6) |> Queue.insert_front(7) |> Queue.to_list
      [7, 6]
      iex> Enum.to_list(1..5) |> Queue.new |> Queue.insert_front(6) |> Queue.to_list
      [6, 1, 2, 3, 4, 5]
  """
  def insert_front(%Queue{q: q}, item) do
    wrap(:queue.in_r(item, q))
  end

  @doc """
  Adds an item to the queue

  ## Example
      iex> Queue.new |> Queue.insert(6) |> Queue.insert(7) |> Queue.to_list
      [6, 7]
      iex> Enum.to_list(1..5) |> Queue.new |> Queue.insert(6) |> Queue.to_list
      [1, 2, 3, 4, 5, 6]
  """
  def insert(%Queue{q: q}, item) do
    wrap(:queue.in(item, q))
  end

  @doc """
  Returns the front Item of the queue.

  ## Example
      iex> Queue.new([:ok, "b", "c"]) |> Queue.peek
      :ok
      iex> Queue.new([%{foo: :bar}, "b", "c"]) |> Queue.peek
      %{foo: :bar}
  """
  def peek(%Queue{q: q}) do
    :queue.peek(q) |> item_or_nil
  end

  @doc """
  Returns the Item at the rear of the queue.

  ## Example
      iex> Queue.new(["a", "b", "c"]) |> Queue.peek_rear
      "c"
  """
  def peek_rear(%Queue{q: q}) do
    :queue.peek_r(q) |> item_or_nil
  end

  @doc """
  Removes the item at the rear of the queue.
  Returns {item, Queue}, or {nil, Queue} if Queue is empty.

  ## Example
      iex> Queue.new |> Queue.pop_rear
      {nil, %Queue{q: {[], []}}}
      iex> Enum.to_list(1..5) |> Queue.new |> Queue.pop_rear
      {5, %Queue{q: {[4], [1, 2, 3]}}}
  """
  def pop_rear(%Queue{q: q}) do
    :queue.out_r(q) |> item_queue_or_nil
  end

  @doc """
  Removes the item at the front of the queue.
  Returns {item, Queue}, or {nil, Queue} if Queue is empty.

  ## Example
      iex> Queue.new |> Queue.pop
      {nil, %Queue{q: {[], []}}}
      iex> Enum.to_list(1..5) |> Queue.new |> Queue.pop
      {1, %Queue{q: {[5, 4], [2, 3]}}}
  """
  def pop(%Queue{q: q}) do
    :queue.out(q) |> item_queue_or_nil
  end

  @doc """
  Returns true if the queue is empty, false otherwise.

  ## Example
      iex> Queue.new |> Queue.empty?
      true
      iex> Enum.to_list(1..5) |> Queue.new |> Queue.empty?
      false
  """
  def empty?(%Queue{q: q}) do
    :queue.is_empty(q)
  end

  @doc """
  Returns a new queue with only truthy items

  ## Example
      iex> Enum.to_list(1..5) |> Queue.new |> Queue.filter(fn x -> x == 6 end)
      %Queue{q: {[], []}}
      iex> Enum.to_list(1..5) |> Queue.new |> Queue.filter(fn x -> x != 1 end)
      %Queue{q: {[5, 4], [2, 3]}}
  """
  def filter(%Queue{q: q}, fun) do
    wrap(:queue.filter(fn item -> fun.(item) end, q))
  end

  @doc """
  Returns a new queue after applying fun to each element.

  ## Example
      iex> Enum.to_list(1000..1005) |> Queue.new |> Queue.map(fn x -> x + 6 end) |> Queue.to_list()
      [1006, 1007, 1008, 1009, 1010, 1011]
      iex> Enum.to_list(1000..1005) |> Queue.new |> Queue.map(fn x -> x + 6 end)
      %Queue{q: {[1011, 1010], [1006, 1007, 1008, 1009]}}
      iex> Enum.to_list(1000..1005) |> Queue.new |> Queue.map(fn x -> if x == 1004, do: true, else: x end) |> Queue.to_list()
      [1000, 1001, 1002, 1003, true, 1005]
  """
  def map(%Queue{} = queue, fun) when is_function(fun, 1) do
    queue
    |> to_list()
    |> Enum.map(&fun.(&1))
    |> new()
  end

  def any?(%Queue{} = queue, fun) when is_function(fun, 1) do
    queue
    |> to_list()
    |> Enum.any?(&fun.(&1))
  end

  defp wrap(q) do
    %Queue{q: q}
  end

  defp item_or_nil(:empty), do: nil
  defp item_or_nil({:value, val}), do: val

  defp item_queue_or_nil({:empty, q}), do: {nil, wrap(q)}
  defp item_queue_or_nil({{:value, val}, q}), do: {val, wrap(q)}
end
