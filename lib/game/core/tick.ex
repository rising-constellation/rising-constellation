defmodule Core.Tick do
  use TypedStruct

  alias Core.Tick
  alias Instance.Time.Time

  # set the UNIT TIME to 1 day in normal speed
  @unit_time_divider 180_000
  @speedup String.to_integer(System.get_env("SPEEDUP", "1"))
  @millisecond_padding (50 / @speedup) |> Kernel.round() |> Kernel.max(1)

  typedstruct enforce: true do
    field(:time, integer())
    field(:cumulated_pauses, integer() | nil, default: nil)
    field(:factor, integer())
    field(:ref, reference(), enforce: false)
    field(:running?, boolean(), default: false)
  end

  def new(factor) do
    %Core.Tick{time: Time.now(), factor: factor * @speedup, cumulated_pauses: nil}
  end

  def start(%Tick{cumulated_pauses: cumulated_pauses} = state) do
    ref = Process.send_after(self(), :tick, 0)
    %{state | time: Time.now(cumulated_pauses), ref: ref, running?: true}
  end

  def next(%Tick{cumulated_pauses: cumulated_pauses} = state, :never) do
    unless state.ref == nil,
      do: Process.cancel_timer(state.ref)

    %{state | time: Time.now(cumulated_pauses), ref: nil}
  end

  def next(%Tick{cumulated_pauses: cumulated_pauses} = state, interval) do
    unless state.ref == nil,
      do: Process.cancel_timer(state.ref)

    ref = Process.send_after(self(), :tick, interval)
    %{state | time: Time.now(cumulated_pauses), ref: ref}
  end

  def stop(%Tick{} = state) do
    unless state.ref == nil,
      do: Process.cancel_timer(state.ref)

    %{state | ref: nil, running?: false}
  end

  def delta(%Tick{cumulated_pauses: cumulated_pauses} = state) do
    (Time.now(cumulated_pauses) - state.time) * state.factor / @unit_time_divider
  end

  # TODO: set a "max milisecond" time when never
  def unit_time_to_millisecond(_state, :never),
    do: :never

  def unit_time_to_millisecond(state, unit_time) do
    millisecond =
      (unit_time / state.factor * @unit_time_divider)
      |> Float.ceil()
      |> Kernel.trunc()

    millisecond + @millisecond_padding
  end

  def millisecond_to_unit_time(milliseconds, factor) do
    milliseconds * factor / @unit_time_divider
  end
end
