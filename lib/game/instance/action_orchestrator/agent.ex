defmodule Instance.ActionOrchestrator.Agent do
  use Core.TickServer

  alias Instance.Character.Action
  alias Instance.Character.ActionQueue
  alias Instance.Character.Character

  require Logger
  require TimeLog

  @decorate tick()
  def on_call(:get_state, _from, state) do
    {:reply, {:ok, state}, state}
  end

  def on_cast({hook_type, %Character{} = character, %Action{} = action}, state) do
    character = %{character | actions: ActionQueue.unlock(character.actions)}

    result =
      TimeLog.execute "orchestrator: #{inspect(action)} executed #{inspect(hook_type)}" do
        try do
          Instance.Character.Agent.orchestrated(hook_type, action, character)
        rescue
          exception ->
            Appsignal.Instrumentation.set_error(exception, __STACKTRACE__)

            Logger.error(
              "orchestrator exec #{inspect(hook_type)} #{inspect(action)} raised #{inspect(exception)} #{inspect(__STACKTRACE__)}"
            )

            {:ok, character}
        end
      end

    case result do
      {:ok, %Character{} = character} ->
        try do
          Game.call(character.instance_id, :character, character.id, {:done, hook_type, character})
        rescue
          exception ->
            Appsignal.Instrumentation.set_error(exception, __STACKTRACE__)
            Logger.error("orchestrator cannot reach the character (he is probably dead)")
        end

      {:ok, something} ->
        Logger.warn("orchestrator did not get a character #{inspect(something)}")

      something_else ->
        Logger.warn("orchestrator did not succeed #{inspect(something_else)}")
    end

    {:noreply, state}
  end

  @decorate tick()
  def on_info(:tick, state) do
    {:noreply, state}
  end

  defp do_next_tick(state, _elapsed_time) do
    {state, Instance.ActionOrchestrator.ActionOrchestrator}
  end
end
