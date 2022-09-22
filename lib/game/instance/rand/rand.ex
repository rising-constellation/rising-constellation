defmodule Instance.Rand.Rand do
  use TypedStruct

  alias Instance.Rand.Rand

  typedstruct enforce: true do
    field(:rand_state, any())
  end

  def new(seed) do
    rand_state = :rand.seed(:exrop, seed)

    %Rand{
      rand_state: rand_state
    }
  end

  def compute_next_tick_interval(_state) do
    :never
  end

  # Tick handling

  def next_tick(state, _elapsed_time) do
    {:no_update, state}
  end
end
