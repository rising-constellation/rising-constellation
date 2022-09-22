defmodule Instance.Time.Time do
  use TypedStruct

  require Logger

  alias Instance.Time.Time
  alias Instance.Manager
  alias RC.InstanceSnapshots
  alias RC.Instances.InstanceSnapshot

  @next_autosave_ticks 20
  @max_autosaves 5

  def jason(), do: [except: [:instance_id, :next_autosave]]

  typedstruct enforce: true do
    field(:is_running, boolean())
    field(:speed, atom())
    field(:now, %Core.DynamicValue{})
    field(:last_stop, integer() | nil)
    field(:cumulated_pauses, integer())
    field(:now_monotonic, integer() | nil)
    field(:next_autosave, %Core.DynamicValue{})
    field(:instance_id, integer())
  end

  def new(initial_date, day_factor, speed, instance_id) do
    now =
      Core.DynamicValue.new(initial_date)
      |> Core.DynamicValue.add(:misc, Core.ValuePart.new(:time, day_factor))

    %Instance.Time.Time{
      is_running: false,
      speed: speed,
      now: now,
      last_stop: nil,
      cumulated_pauses: 0,
      now_monotonic: nil,
      next_autosave: Core.DynamicValue.new(0, :misc, Core.ValuePart.new(:default, 1)),
      instance_id: instance_id
    }
  end

  def compute_next_tick_interval(_state) do
    5
  end

  def start(%Time{} = state) do
    %{state | is_running: true, cumulated_pauses: compute_cumulated_pauses(state)}
  end

  def stop(%Time{} = state) do
    %{state | is_running: false, last_stop: now()}
  end

  # Tick handling

  def next_tick(%Time{} = state, elapsed_time) do
    {MapSet.new(), state}
    |> update_now(elapsed_time)
    |> update_next_autosave(elapsed_time)
  end

  # Core functions

  defp update_now({change, state}, elapsed_time) do
    {change, %{state | now: Core.DynamicValue.next_tick(state.now, elapsed_time)}}
  end

  defp update_next_autosave({change, %{speed: :slow, is_running: true} = state}, elapsed_time) do
    next_autosave = Core.DynamicValue.next_tick(state.next_autosave, elapsed_time)

    next_autosave =
      if next_autosave.value >= @next_autosave_ticks do
        Task.start(fn ->
          with {:ok, :stopped, _} <- Manager.call(state.instance_id, :stop, 180_000),
               {:ok, _snapshot} <- Manager.call(state.instance_id, :make_snapshot, 300_000),
               {:ok, :started, _} <- Manager.call(state.instance_id, :start, 180_000) do
            # only keep @max_autosaves most recent snapshots
            InstanceSnapshots.list(state.instance_id)
            |> Enum.drop(@max_autosaves)
            |> Enum.each(fn snapshot ->
              with :ok <- Util.Storage.delete(snapshot.name),
                   {:ok, %InstanceSnapshot{}} <- InstanceSnapshots.delete(snapshot) do
                nil
              else
                _ -> Logger.error("Error during autosave cleaning")
              end
            end)
          else
            {:error, _err} -> Logger.error("Error during autosave")
          end
        end)

        Core.DynamicValue.change_value(next_autosave, 0.0)
      else
        next_autosave
      end

    {change, %{state | next_autosave: next_autosave}}
  end

  defp update_next_autosave({change, state}, _elapsed_time) do
    {change, state}
  end

  # Helper functions

  def compute_cumulated_pauses(%Time{last_stop: nil} = _state), do: 0
  def compute_cumulated_pauses(%Time{} = state), do: state.cumulated_pauses + (Time.now() - state.last_stop)

  def now(cumulated_pauses), do: System.monotonic_time(:millisecond) - cumulated_pauses
  def now(), do: System.monotonic_time(:millisecond)
end
