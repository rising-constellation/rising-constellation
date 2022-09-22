defmodule Instance.ActionOrchestrator.ActionOrchestrator do
  use TypedStruct

  alias Instance.ActionOrchestrator.ActionOrchestrator

  typedstruct enforce: true do
    field(:instance_id, integer())
  end

  def new(instance_id) do
    %ActionOrchestrator{instance_id: instance_id}
  end

  def compute_next_tick_interval(_state) do
    :never
  end

  # Tick handling

  def next_tick(state, _elapsed_time) do
    {:no_update, state}
  end
end
