defmodule Core.TickServer do
  # Macros for modules using `TickServer`

  defmacro __using__(_params) do
    quote do
      require Logger

      use GenServer
      use Util.TickDecorator

      @before_compile Core.TickServer

      def init(state) do
        Process.flag(:trap_exit, true)
        {:ok, state, {:continue, :load_state}}
      end

      def handle_continue(:load_state, state) do
        {:noreply, load_state(state)}
      end

      def handle_call(arg, from, state) do
        state = if arg == :stop, do: next_tick(state), else: state
        result = on_call(arg, from, state)

        case result do
          {:reply, _reply, new_state} -> new_state
          {:reply, _reply, new_state, _arg2} -> new_state
          {:noreply, new_state} -> new_state
          {:noreply, new_state, _arg2} -> new_state
          {:stop, _reason, _reply, new_state} -> new_state
          {:stop, _reason, new_state} -> new_state
        end
        |> save_state()

        result
      end

      def handle_cast(request, state) do
        result = on_cast(request, state)

        case result do
          {:noreply, new_state} -> new_state
          {:noreply, new_state, _arg2} -> new_state
          {:stop, _reason, new_state} -> new_state
        end
        |> save_state()

        result
      end

      def handle_info(msg, state) do
        result = on_info(msg, state)

        case result do
          {:noreply, new_state} -> new_state
          {:noreply, new_state, _arg2} -> new_state
          {:stop, _reason, new_state} -> new_state
        end
        |> save_state()

        result
      end

      def terminate(:shutdown, %{kill: true}) do
        # process is terminated by the manager, don't save its state
        :ok
      end

      def terminate(_reason, state) do
        # process is dying, save handoff state
        name_tuple = Core.GenState.registry_name(state)
        Horde.Registry.unregister(Game.Registry, name_tuple)
        Data.GenServerState.save(name_tuple, state, __MODULE__)
        Process.sleep(10_000)
      end

      def start_link(opts), do: Core.TickServer.start_link(opts, __MODULE__)

      def next_tick(%{tick: %{running?: false}} = state), do: state

      def next_tick(state) do
        {state, module} = do_next_tick(state, Core.Tick.delta(state.tick))
        next_tick = module.compute_next_tick_interval(state.data)
        next_tick = Core.Tick.unit_time_to_millisecond(state.tick, next_tick)

        # This will print every tick_servers' tick
        # print_tick_data(state, next_tick, [])

        # This will print only player and stellar_systems tick_servers' tick
        # print_tick_data(state, next_tick, [:player, :stellar_system])

        %{state | tick: Core.Tick.next(state.tick, next_tick)}
      end

      def print_tick_data(state, next_tick, only) do
        if Enum.empty?(only) or Enum.any?(only, fn type -> state.type == type end) do
          process_name = "#{state.type}:#{state.agent_id}"

          next_tick =
            if next_tick == :never,
              do: ":never",
              else: "in #{next_tick / 1000}s"

          Logger.info("#{String.pad_trailing(process_name, 25)} next tick #{next_tick}")
        end
      end

      defp load_state(state) do
        # try loading handoff data (load it if it's there)
        name_tuple = Core.GenState.registry_name(state)
        Horde.Registry.register(Game.Registry, name_tuple, self())

        case Data.GenServerState.retrieve_delete(name_tuple) do
          {:ok, %{state: state_to_restore}} ->
            state_to_restore

          :error ->
            state
        end
      end

      defp save_state(state) do
        # Core.GenState.registry_name(new_state)
        # |> Data.GenServerState.save(new_state, __MODULE__)
      end
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      defdelegate on_call(message, from, state), to: Core.TickServer
      defdelegate on_cast(request, state), to: Core.TickServer
      defdelegate on_info(msg, state), to: Core.TickServer
    end
  end

  # Client

  def start_link(opts, module) do
    state = Keyword.get(opts, :state)

    case GenServer.start_link(module, state, name: Game.via_tuple(Core.GenState.registry_name(state))) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, _pid}} -> :ignore
    end
  end

  # SERVER - default implementations used by *.Agent,
  # these are called via defdelegate in case they are not already defined,
  # for instance Time.Agent defines {:start, …} so this {:start, …} won't get called

  def on_call({:start, cumulated_pauses}, _from, state),
    do: {:reply, :ok, %{state | tick: Core.Tick.start(%{state.tick | cumulated_pauses: cumulated_pauses})}}

  def on_call(:stop, _from, state),
    do: {:reply, :ok, %{state | tick: Core.Tick.stop(state.tick)}}

  def on_call(:get_full_state, _from, state),
    do: {:reply, state, state}

  # call this before terminating a process to ensure it does not get restarted
  def on_call(:prepare_kill, _from, state),
    do: {:reply, :ok, %{state | kill: true}}

  # insert dummy implementations of on_call/on_cast/on_info at the end of the module
  # otherwise we end up with e.g. `undefined function on_info/2` in cas the module
  # using TickServer does not contain an (e.g.) on_info/2
  def on_call(_arg, _from, _state), do: throw(:not_implemented)
  def on_cast(_request, _state), do: throw(:not_implemented)
  def on_info(_msg, _state), do: throw(:not_implemented)
end
