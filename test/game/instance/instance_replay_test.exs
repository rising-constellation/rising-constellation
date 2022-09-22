# defmodule Game.Instance.ReplayTest do
#   use Game.InstanceCase
#   use Portal.APIConnCase

#   alias Game.InstanceCase

#   @moduletag :replays

#   setup do
#     Ecto.Adapters.SQL.Sandbox.mode(RC.Repo, {:shared, self()})

#     if System.get_env("SPEEDUP", "1") |> String.to_integer() > 120 do
#       IO.puts("Warning: if logs are showing a lot of actions being replayed too late, lower the speedup value")
#     end

#     :ok
#   end

#   @tag timeout: :infinity
#   test "replay" do
#     concurrency = Kernel.max(System.schedulers_online() - 2, 2)

#     IO.puts(
#       "STARTING REPLAYS WITH A #{System.get_env("SPEEDUP", "1")}x SPEEDUP on #{concurrency}/#{
#         System.schedulers_online()
#       } threads"
#     )

#     InstanceCase.available_replays()
#     |> Enum.each(fn filename ->
#       %{
#         objects: objects,
#         instance: instance,
#         actions: actions
#       } = InstanceCase.prepare_replay("./replays/#{filename}")

#       IO.puts("Replaying: #{filename}")

#       total = length(actions)

#       # game must be started before register_profiles
#       {:ok, :started, _} = Instance.Manager.call(instance.id, :start)

#       # register_profiles must be done after the game started
#       objects = InstanceCase.register_profiles(objects)
#       objects_agent = start_supervised!({Agent, fn -> objects end}, id: :objects_agent)

#       agent_state = %{errors: %{}, errors_by_profile: %{}, first_ts: nil}
#       state_agent = start_supervised!({Agent, fn -> agent_state end}, id: :state_agent)

#       # replay only the first N actions
#       actions_to_replay =
#         actions
#         # |> Enum.slice(0, 1000)
#         |> Enum.with_index()

#       first_action_time = List.first(actions)["timestamp"]
#       first_ts = :os.system_time(:nanosecond)

#       stream =
#         Task.async_stream(
#           actions_to_replay,
#           fn {action, n} ->
#             if Kernel.floor((n - 1) / total * 10) + 1 == Kernel.floor(n / total * 10) do
#               IO.puts("Replayed #{Kernel.floor(n / total * 100)}%")
#             end

#             %{"channel" => channel, "timestamp" => action_datetime, "profile_id" => profile_id} = action

#             time_since_beginning =
#               Kernel.round(
#                 (:os.system_time(:nanosecond) - first_ts) * String.to_integer(System.get_env("SPEEDUP", "1"))
#               )

#             replay_time = DateTime.add(first_action_time, time_since_beginning, :nanosecond)

#             InstanceCase.wait_until(action_datetime, replay_time, "before action")

#             if channel != "none" do
#               wait_for_socket(profile_id, objects_agent)
#             end

#             objects = Agent.get(objects_agent, fn objects -> objects end)

#             time_since_beginning =
#               Kernel.round(
#                 (:os.system_time(:nanosecond) - first_ts) * String.to_integer(System.get_env("SPEEDUP", "1"))
#               )

#             replayed_at_time = DateTime.add(first_action_time, time_since_beginning, :nanosecond)
#             {:reply, result, payload} = InstanceCase.replay(action, objects, {n, total}, replayed_at_time)

#             spawn(fn ->
#               cond do
#                 result == :objects and channel == "none" ->
#                   {key, sockets} = payload

#                   Agent.update(objects_agent, fn objects ->
#                     player_map = Map.merge(objects[key], sockets)

#                     Map.put(objects, key, player_map)
#                   end)

#                 channel == "player" and is_tuple(result) and elem(result, 0) != :ok ->
#                   InstanceCase.handle_error(state_agent, action, result)

#                 true ->
#                   nil
#               end
#             end)
#           end,
#           timeout: :infinity,
#           ordered: false,
#           max_concurrency: concurrency
#         )

#       Stream.run(stream)

#       state = Agent.get(state_agent, fn state -> state end)

#       IO.inspect(state.errors, limit: :infinity, charlists: :as_lists, width: 250)
#       IO.inspect(state.errors_by_profile, limit: :infinity, charlists: :as_lists, width: 250)

#       assert true == true
#     end)
#   end
# end
