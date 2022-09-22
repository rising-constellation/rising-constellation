# defmodule Game.InstanceCase do
#   @moduledoc """
#   This module defines common behaviors shared for Game Instance tests.
#   """
#   import Plug.Conn
#   import Phoenix.ConnTest
#   import Phoenix.ChannelTest
#   use ExUnit.CaseTemplate

#   require Logger
#   require TimeLog

#   @endpoint Portal.Endpoint

#   using do
#     quote do
#       import Phoenix.ChannelTest
#       import Game.InstanceCase

#       require Logger

#       @endpoint Portal.Endpoint
#     end
#   end

#   def get_bearer_token(email, password) do
#     auth = %Ueberauth.Auth{
#       credentials: %Ueberauth.Auth.Credentials{
#         expires: nil,
#         expires_at: nil,
#         other: %{password: password, password_confirmation: nil},
#         refresh_token: nil,
#         scopes: [],
#         secret: nil,
#         token: nil,
#         token_type: nil
#       },
#       info: %Ueberauth.Auth.Info{
#         birthday: nil,
#         description: nil,
#         email: email,
#         first_name: nil,
#         image: nil,
#         last_name: nil,
#         location: nil,
#         name: nil,
#         nickname: email,
#         phone: nil,
#         urls: %{}
#       },
#       provider: :identity,
#       strategy: Ueberauth.Strategy.Identity,
#       uid: email
#     }

#     conn =
#       build_conn()
#       |> bypass_through(Portal.Router, [:api])
#       |> post("/api/auth/identity/callback", %{
#         "account" => %{"email" => email, "password" => password}
#       })
#       |> assign(:ueberauth_auth, auth)
#       |> Portal.AuthenticationController.identity_callback(%{})

#     %{resp_body: body} = conn
#     %{"token" => user_token} = Jason.decode!(body)
#     user_token
#   end

#   def authenticated_get(user_token, instance_id, registration_token) do
#     build_conn()
#     |> put_req_header("accept", "application/json")
#     |> put_req_header("authorization", "Bearer #{user_token}")
#     |> get("/api/instances/#{instance_id}/game/start/#{registration_token}")
#   end

#   def create_model do
#     {:ok, _model} =
#       RC.Instances.create_model(%{
#         name: "test model",
#         description: "test model description",
#         game_data: File.read!("./test/game/test_model.json")
#       })
#   end

#   def create_instance(replay_file) do
#     %{"instance" => instance} = replay_file |> File.read!() |> Jason.decode!()

#     playable_attrs = %{
#       "registration_status" => "open",
#       "maintenance_status" => "none",
#       "game_status" => "open",
#       "display_status" => "detail",
#       "supervisor_status" => ""
#     }

#     {:ok, instance} = RC.Instances.create_instance(Map.merge(instance, playable_attrs))

#     instance
#   end

#   def create_instance do
#     {:ok, instance} =
#       RC.Instances.create_instance(%{
#         "game_data" => File.read!("./test/game/test_instance_data.json"),
#         "metadata" => File.read!("./test/game/test_instance_metadata.json"),
#         "name" => "Test Instance",
#         "opening_date" => "2020-06-07 18:00:00",
#         "registration_status" => "open",
#         "maintenance_status" => "none",
#         "game_status" => "open",
#         "display_status" => "detail",
#         "description" => "test instance description",
#         "supervisor_status" => ""
#       })

#     instance
#   end

#   def create_factions(instance, replay_file) do
#     %{"instance" => %{"factions" => factions}} = replay_file |> File.read!() |> Jason.decode!()

#     factions =
#       factions
#       |> Enum.map(fn faction ->
#         {:ok, faction} = RC.Instances.create_faction(Map.merge(faction, %{"instance_id" => instance.id}))
#         faction
#       end)

#     factions
#   end

#   def prepare_users(factions, replay_file) do
#     %{"instance" => %{"factions" => factions_org}, "registrations" => registrations_org} =
#       replay_file |> File.read!() |> Jason.decode!()

#     # build a map from replay faction_id to inserted faction
#     faction_to_new =
#       factions_org
#       |> Enum.reduce(%{}, fn %{"id" => id, "faction_ref" => faction_ref}, acc ->
#         new_faction = factions |> Enum.find(fn %{faction_ref: ref} -> ref == faction_ref end)
#         Map.put(acc, id, new_faction)
#       end)

#     faction_to_old = faction_to_new |> Map.new(fn {key, %{id: id}} -> {id, key} end)

#     inserted_acc_prof_fact =
#       registrations_org
#       |> Enum.with_index()
#       |> Enum.map(fn {registration, index} ->
#         %{"id" => old_faction_id} = factions_org |> Enum.find(fn %{"id" => id} -> id == registration["faction_id"] end)

#         {profile, account} = create_account_and_profile({"user#{index}@abc", "abc", "user#{index}", :user, :active})

#         faction = faction_to_new[old_faction_id]

#         profile = Map.put(profile, :joined_at, to_datetime(registration["inserted_at"]))

#         {account, profile, faction}
#       end)

#     profile_to_new =
#       Enum.zip(registrations_org, inserted_acc_prof_fact)
#       |> Enum.reduce(%{}, fn {%{"profile_id" => old_profile_id}, {_, profile, _}}, acc ->
#         Map.put(acc, old_profile_id, profile)
#       end)

#     profile_to_old = profile_to_new |> Map.new(fn {key, %{id: id}} -> {id, key} end)

#     {inserted_acc_prof_fact, faction_to_new, profile_to_new, faction_to_old, profile_to_old}
#   end

#   def prepare_actions(actions, inserted_acc_prof_fact, instance_id, profile_to_old) do
#     actions =
#       actions
#       |> Enum.map(fn %{"timestamp" => timestamp} = action ->
#         Map.put(action, "timestamp", to_datetime(timestamp))
#       end)

#     registrations =
#       inserted_acc_prof_fact
#       |> Enum.map(fn {_, %{joined_at: joined_at, id: profile_id}, %{id: faction_id}} ->
#         %{
#           "channel" => "none",
#           "msg" => "register_join",
#           "timestamp" => joined_at,
#           "profile_id" => profile_id,
#           "faction_id" => faction_id,
#           "instance_id" => instance_id,
#           "profile_to_old" => profile_to_old
#         }
#       end)

#     (registrations ++ actions)
#     |> Enum.sort(fn %{"timestamp" => t1}, %{"timestamp" => t2} ->
#       case DateTime.compare(t1, t2) do
#         :lt -> true
#         _ -> false
#       end
#     end)
#   end

#   def prepare_replay(replay_file) do
#     %{"replay" => actions} = replay_file |> File.read!() |> Jason.decode!()

#     instance = create_instance(replay_file)
#     factions = instance |> create_factions(replay_file)

#     Instance.Manager.create_from_model(instance)

#     {inserted_acc_prof_fact, _faction_to_new, _profile_to_new, _faction_to_old, profile_to_old} =
#       prepare_users(factions, replay_file)

#     objects =
#       inserted_acc_prof_fact
#       |> Enum.reduce(%{}, fn {account, profile, faction}, acc ->
#         Map.put(acc, profile_to_old[profile.id], %{
#           account: account,
#           faction: faction,
#           profile: profile,
#           joined: false
#         })
#       end)

#     actions = prepare_actions(actions, inserted_acc_prof_fact, instance.id, profile_to_old)

#     %{
#       objects: objects,
#       instance: instance,
#       actions: actions
#     }
#   end

#   def join_channels(instance_id, faction_id, profile_id, registration_token) do
#     socket = socket(Portal.Socket)

#     {:ok, _, global_socket} =
#       socket
#       |> subscribe_and_join(
#         Portal.Controllers.GlobalChannel,
#         "instance:global:#{instance_id}",
#         %{"registration" => registration_token}
#       )

#     {:ok, _, faction_socket} =
#       socket
#       |> subscribe_and_join(
#         Portal.Controllers.FactionChannel,
#         "instance:faction:#{instance_id}:#{faction_id}",
#         %{"registration" => registration_token}
#       )

#     {:ok, _, player_socket} =
#       socket
#       |> subscribe_and_join(
#         Portal.Controllers.PlayerChannel,
#         "instance:player:#{faction_id}:#{profile_id}",
#         %{"registration" => registration_token}
#       )

#     %{
#       global_socket: global_socket,
#       faction_socket: faction_socket,
#       player_socket: player_socket,
#       joined: true
#     }
#   end

#   def create_account_and_profile({email, pwd, pseudo, role, status}) do
#     {:ok, account} =
#       RC.Accounts.create_account(%{
#         email: email,
#         password: pwd,
#         name: pseudo,
#         role: role,
#         status: status
#       })

#     account = Map.put(account, :password, pwd)

#     {:ok, _log} =
#       RC.Logs.create_log(
#         %{action: :create_account},
#         account
#       )

#     {:ok, profile} =
#       RC.Accounts.create_profile(%{
#         avatar: "todo",
#         name: account.name,
#         account_id: account.id
#       })

#     {profile, account}
#   end

#   def register_profiles(objects) do
#     objects
#     |> Enum.reduce(%{}, fn {profile_id, object}, acc ->
#       {_faction, _profile, registration} =
#         RC.Registrations.register_profile(object.faction.instance_id, object.faction.id, object.profile.id)

#       object = Map.put(object, :registration, registration)

#       Map.put(acc, profile_id, object)
#     end)
#   end

#   def replay(%{"channel" => "none", "msg" => "register_join"} = payload, objects, {n, total}, replay_time) do
#     %{
#       "profile_id" => profile_id,
#       "faction_id" => _faction_id,
#       "timestamp" => timestamp,
#       "instance_id" => instance_id,
#       "profile_to_old" => profile_to_old
#     } = payload

#     old_profile_id = profile_to_old[profile_id]
#     faction = objects[old_profile_id].faction
#     profile = objects[old_profile_id].profile
#     registration = objects[old_profile_id].registration

#     Logger.info("#{n + 1}/#{total}\tentering the game: [#{profile_id}]\t#{old_profile_id}")

#     log_shift(replay_time, timestamp)

#     Instance.Manager.call(instance_id, {:add_player, faction, profile, registration.id})

#     sockets = join_channels(instance_id, faction.id, profile.id, registration.token)

#     key = old_profile_id
#     {:reply, :objects, {key, sockets}}
#   end

#   def replay(%{"channel" => "global"} = payload, objects, {n, total}, replay_time) do
#     %{"msg" => msg, "params" => params, "profile_id" => profile_id, "timestamp" => timestamp} = payload
#     Logger.info("#{n + 1}/#{total}\treplaying global #{profile_id}")
#     log_shift(replay_time, timestamp)
#     Portal.Controllers.GlobalChannel.handle_in(msg, params, objects[profile_id].global_socket)
#   end

#   def replay(%{"channel" => "player", "msg" => "get_reports"} = payload, _objects, {n, total}, replay_time) do
#     %{"timestamp" => timestamp} = payload
#     # %{"msg" => msg, "params" => params, "profile_id" => profile_id} = payload
#     Logger.info("#{n + 1}/#{total}\tskipping 'get_reports'")
#     log_shift(replay_time, timestamp)
#     # Portal.Controllers.PlayerChannel.handle_in(msg, params, objects[profile_id].player_socket)
#     {:reply, :ok, nil}
#   end

#   def replay(%{"channel" => "player", "msg" => "hide_report"} = payload, _objects, {n, total}, replay_time) do
#     %{"timestamp" => timestamp} = payload
#     # %{"msg" => msg, "params" => params, "profile_id" => profile_id} = payload
#     Logger.info("#{n + 1}/#{total}\tskipping 'hide_report'")
#     log_shift(replay_time, timestamp)
#     # Portal.Controllers.PlayerChannel.handle_in(msg, params, objects[profile_id].player_socket)
#     {:reply, :ok, nil}
#   end

#   def replay(%{"channel" => "player"} = payload, objects, {n, total}, replay_time) do
#     %{"msg" => msg, "params" => params, "profile_id" => profile_id, "timestamp" => timestamp} = payload
#     Logger.info("#{n + 1}/#{total}\treplaying player [#{objects[profile_id].profile.id}] #{profile_id}\t#{msg}")
#     log_shift(replay_time, timestamp)
#     Portal.Controllers.PlayerChannel.handle_in(msg, params, objects[profile_id].player_socket)
#   end

#   def replay(%{"channel" => "player", "msg" => "order_building"} = payload, objects, {n, total}, replay_time) do
#     %{"msg" => msg, "params" => params, "profile_id" => profile_id, "timestamp" => timestamp} = payload
#     Logger.info("#{n + 1}/#{total}\treplaying player [#{objects[profile_id].profile.id}] #{profile_id}\t#{msg}")
#     log_shift(replay_time, timestamp)
#     Portal.Controllers.PlayerChannel.handle_in(msg, params, objects[profile_id].player_socket)
#   end

#   def replay(%{"channel" => "faction"} = payload, objects, {n, total}, replay_time) do
#     %{"msg" => msg, "params" => params, "profile_id" => profile_id, "timestamp" => timestamp} = payload
#     Logger.info("#{n + 1}/#{total}\treplaying faction #{profile_id}")
#     log_shift(replay_time, timestamp)
#     Portal.Controllers.FactionChannel.handle_in(msg, params, objects[profile_id].faction_socket)
#   end

#   def to_datetime(%{"timestamp" => timestring}) do
#     timestring
#     |> NaiveDateTime.from_iso8601!()
#     |> DateTime.from_naive!("Etc/UTC")
#   end

#   def to_datetime(timestring) do
#     timestring
#     |> NaiveDateTime.from_iso8601!()
#     |> DateTime.from_naive!("Etc/UTC")
#   end

#   def wait(ms, msg \\ "")

#   def wait(virtual_ms, _msg) when is_integer(virtual_ms) do
#     speedup = String.to_integer(System.get_env("SPEEDUP", "1"))
#     ms = Kernel.round(virtual_ms / speedup)

#     if ms > 0 do
#       # if String.length(msg) do
#       #   IO.puts("waiting #{ms}ms (#{virtual_ms}ms) " <> msg)
#       # end

#       Process.sleep(ms)
#     end

#     virtual_ms
#   end

#   def wait(ms, msg) when is_float(ms) do
#     wait(Kernel.round(ms), msg)
#   end

#   def wait_until(exec_time, current_time, msg \\ "") do
#     diff = DateTime.diff(exec_time, current_time, :millisecond)

#     virtual_ms =
#       if diff < 0 do
#         0
#       else
#         wait(diff, msg)
#       end

#     DateTime.add(current_time, virtual_ms, :millisecond)
#   end

#   def log_shift(replay_time, datetime) do
#     delay = DateTime.diff(replay_time, datetime, :millisecond)

#     cond do
#       delay < -100 ->
#         IO.puts("expected at: #{datetime}")
#         delay = DateTime.diff(replay_time, datetime, :second)
#         IO.puts("executed at: #{replay_time} (#{delay}s too early)")

#       delay > 1000 ->
#         IO.puts("expected at: #{datetime}")
#         delay = DateTime.diff(replay_time, datetime, :second)
#         IO.puts("executed at: #{replay_time} (#{delay}s too late)")

#       true ->
#         Logger.info("(on time)")
#         nil
#     end
#   end

#   def wait_for_socket(profile_id, objects_agent, n \\ 0) do
#     sockets_setup =
#       Agent.get(objects_agent, fn objects ->
#         player_map = objects[profile_id]
#         Map.has_key?(player_map, :faction_socket)
#       end)

#     unless sockets_setup do
#       Process.sleep(4)
#       wait_for_socket(profile_id, objects_agent, n + 1)
#     end
#   end

#   def available_replays() do
#     File.ls!("./replays")
#     |> Enum.filter(&String.ends_with?(&1, ".json"))
#   end

#   def handle_error(state_agent, action, result) do
#     {:error, %{reason: reason}} = result

#     Agent.update(state_agent, fn %{errors: errors, errors_by_profile: errors_by_profile} = state ->
#       errors = Map.update(errors, reason, 1, fn n -> n + 1 end)

#       errors_by_profile = Map.update(errors_by_profile, action["profile_id"], [], fn n -> n ++ [reason] end)

#       %{state | errors: errors, errors_by_profile: errors_by_profile}
#     end)

#     Logger.warn(inspect(reason))
#   end
# end
