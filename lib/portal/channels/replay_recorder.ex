defmodule Portal.ReplayRecorder do
  require Logger

  defmacro __using__(_opts) do
    quote do
      require Logger
      import Portal.ReplayRecorder
    end
  end

  defmacro record(msg, params, socket, do: block) do
    quote do
      def unquote(:handle_in)(unquote(msg), unquote(params), unquote(socket)) do
        hyg_socket = unquote(socket)
        ref = socket_ref(hyg_socket)

        Task.start(fn ->
          {duration, result} = :timer.tc(fn -> unquote(block) end)

          record_action(unquote(msg), unquote(params), unquote(socket), result, duration)
          reply(ref, result)
        end)

        {:noreply, hyg_socket}
      end
    end
  end

  def record_action(
        msg,
        params,
        %{assigns: %{player_id: player_id, instance_id: instance_id, channel_name: channel, has_replay: true}},
        result,
        duration
      ) do
    spawn(fn ->
      case RC.Replays.create_replay(%{
             instance_id: instance_id,
             msg: msg,
             params: params,
             channel: channel,
             profile_id: player_id,
             timestamp: DateTime.utc_now(),
             result: inspect(result),
             duration: duration
           }) do
        {:error, %Ecto.Changeset{errors: errors}} ->
          Logger.error("replay insert error #{inspect(errors)}", instance_id: instance_id)

        _ ->
          nil
      end
    end)
  end

  def record_action(_msg, _params, _socket, _result, _duration),
    do: nil
end
