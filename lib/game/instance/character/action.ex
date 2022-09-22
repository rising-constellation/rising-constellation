defmodule Instance.Character.Action do
  use TypedStruct

  alias Instance.Character
  alias Instance.Character.Action

  def jason(), do: []

  typedstruct enforce: true do
    field(:type, atom())
    field(:data, %{})
    field(:total_time, float() | atom())
    field(:remaining_time, float() | atom())
    field(:started_at, integer() | nil)
    field(:cumulated_pauses, integer() | nil)
  end

  def new({type, data, time}) do
    %Character.Action{
      type: type,
      data: data,
      total_time: time,
      remaining_time: time,
      started_at: nil,
      cumulated_pauses: nil
    }
  end

  def reset_time(%Action{} = action, time) do
    %{action | total_time: time, remaining_time: time}
  end

  def start(%Action{} = action, cumulated_pauses) do
    %{action | started_at: Instance.Time.Time.now(cumulated_pauses), cumulated_pauses: cumulated_pauses}
  end

  def compute_remaining_time(%Action{} = action, time_since_last_tick, cumulated_pauses) do
    cond do
      is_nil(action.started_at) and action.total_time == action.remaining_time ->
        action = start(action, cumulated_pauses)
        {:start, action}

      action.remaining_time >= time_since_last_tick ->
        {:unfinished, %{action | remaining_time: action.remaining_time - time_since_last_tick}}

      true ->
        {:finished, time_since_last_tick - action.remaining_time}
    end
  end

  @doc """
  Computes the current progress of an Action
  """
  def compute_progress(%Action{} = action, factor) do
    %Action{
      started_at: started_at,
      remaining_time: remaining_time,
      total_time: total_time,
      cumulated_pauses: cumulated_pauses
    } = action

    cond do
      is_nil(started_at) ->
        0.0

      remaining_time <= 0 ->
        1.0

      true ->
        now = Instance.Time.Time.now(cumulated_pauses)

        (factor * (now - started_at) / (180_000 * total_time))
        |> Float.round(5)
    end
  end
end
