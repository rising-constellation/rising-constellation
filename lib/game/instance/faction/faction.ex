defmodule Instance.Faction.Faction do
  use TypedStruct
  use Util.MakeEnumerable

  alias Instance.Faction
  alias Instance.Faction.Market
  alias Spatial
  alias Spatial.Disk
  alias Spatial.Position
  alias Instance.StellarSystem.StellarSystem

  # Interval between two 'ticks', mainly uses for radar checks
  # Unit is `game_days`.
  # Set on 3 days, meaning:
  # speed :fast -> every 4.5 seconds
  # speed :medium -> every 27 seconds
  # speed :long -> every 9 minutes
  @tick_interval 3
  @max_chat_messages 80
  @max_length_message 500

  def jason(), do: [except: [:instance_id, :all_radars]]

  typedstruct enforce: true do
    field(:id, integer())
    field(:key, atom())
    field(:players, [%Faction.Player{}])
    field(:chat, [%Faction.ChatMessage{}])
    field(:contacts, %{})
    field(:all_radars, %{})
    field(:radars, %{})
    field(:detected_objects, [])
    field(:market_taxes, %Market{})
    field(:instance_id, integer())
  end

  def new(faction, instance_id) do
    %Faction.Faction{
      id: faction.id,
      key: String.to_existing_atom(faction.faction_ref),
      players: [],
      chat: [],
      contacts: %{},
      all_radars: %{},
      radars: %{},
      detected_objects: [],
      market_taxes: Market.new(),
      instance_id: instance_id
    }
  end

  def compute_next_tick_interval(_state) do
    @tick_interval + :rand.uniform(200) / 1000
  end

  # Action handling

  def add_player(state, player) do
    %{state | players: [Faction.Player.convert(player) | state.players]}
  end

  def get_player_name(state, player_id) do
    player = Enum.find(state.players, fn player -> player.id == player_id end)

    unless is_nil(player),
      do: player.name,
      else: "unknown player"
  end

  def get_system_contact(state, system_id) do
    Map.get(state.contacts, system_id, Core.VisibilityValue.new())
  end

  def drop_system_explorer(state, system_id, player_name) do
    contact = Map.get(state.contacts, system_id, Core.VisibilityValue.new())

    {response, contact} =
      if Map.has_key?(contact.details, :explorer) do
        {:already_dropped, contact}
      else
        {:dropped, Core.VisibilityValue.add(contact, :explorer, Core.ValuePart.new(player_name, 1))}
      end

    state = %{state | contacts: Map.put(state.contacts, system_id, contact)}
    {response, contact, state}
  end

  def drop_system_informer(state, _player_name, _system_id, 0),
    do: {MapSet.new(), nil, state}

  def drop_system_informer(state, system_id, player_name, count) do
    contact = Map.get(state.contacts, system_id, Core.VisibilityValue.new())

    contact =
      Enum.reduce(1..count, contact, fn _i, acc ->
        Core.VisibilityValue.add(acc, :informer, Core.ValuePart.new(player_name, 1))
      end)

    state = %{state | contacts: Map.put(state.contacts, system_id, contact)}
    state = %{state | radars: filter_radar_by_visibility(state)}

    {MapSet.new([:dropped, :radar_update]), contact, state}
  end

  def remove_informer(state, system_id) do
    contact =
      state
      |> get_system_contact(system_id)
      |> Core.VisibilityValue.remove(:informer)

    state = %{state | contacts: Map.put(state.contacts, system_id, contact)}
    state = %{state | radars: filter_radar_by_visibility(state)}

    {MapSet.new([:radar_update]), state}
  end

  def resolve_system_visibility(state, system) do
    contact = get_system_contact(state, system.id)

    contact =
      if Enum.any?(system.characters, fn c -> c.owner.faction == state.key end),
        do: Core.VisibilityValue.apply_minimum(contact, Core.ValuePart.new(:agent_on_system, 2)),
        else: contact

    contact =
      if system.owner != nil and system.owner.faction == state.key,
        do: Core.VisibilityValue.apply_minimum(contact, Core.ValuePart.new(:own_faction, 5)),
        else: contact

    # TODO
    # ajouter les modificateurs contextuel
    # - en guerre -> -1
    # - allié -> +1

    contact
  end

  def resolve_character_visibility(state, system, character) do
    contact = resolve_system_visibility(state, system)

    if character.owner.faction == state.key,
      do: 5,
      else: contact.value
  end

  def push_message(state, from, message) do
    message =
      if String.length(message) > @max_length_message,
        do: String.slice(message, 0..@max_length_message) <> " [...]",
        else: message

    chat = List.flatten(state.chat, [Faction.ChatMessage.new(from, message)])

    chat =
      if length(chat) > @max_chat_messages do
        [_ | tail] = chat
        tail
      else
        chat
      end

    %{state | chat: chat}
  end

  def radar_update(%{all_radars: all_radars} = state, %StellarSystem{} = system) do
    all_radars =
      if system.radar.value <= 0 or is_nil(system.owner) do
        Map.delete(all_radars, system.id)
      else
        c = Data.Querier.one(Data.Game.Constant, state.instance_id, :main)

        new_radar = %{
          faction_id: system.owner.faction_id,
          disk: %Disk{
            x: system.position.x,
            y: system.position.y,
            radius: system.radar.value * c.system_base_radar_size
          }
        }

        Map.update(all_radars, system.id, new_radar, fn _ -> new_radar end)
      end

    state = %{state | all_radars: all_radars}
    {:radar_update, %{state | radars: filter_radar_by_visibility(state)}}
  end

  # Tick handling

  def next_tick(state, elapsed_time) do
    {MapSet.new(), state}
    |> Market.lower_market_taxes(elapsed_time)
    |> update_detected_object()
    |> detect_changes(state)
  end

  # Core functions

  defp update_detected_object({change, state}) do
    # TODO: filter les radars :
    # - si ma faction -> go
    # - si pas ma faction -> check visibility -> si 5 go

    characters_in_radar =
      state.radars
      |> Map.values()
      |> Task.async_stream(fn radar -> Spatial.nearby(radar.disk, state.instance_id) end)
      |> Stream.flat_map(fn {:ok, results} -> results end)
      |> Task.async_stream(
        fn {disk, found} ->
          # fetch the exact position of all nearby characters
          with "c-" <> character_id <- found,
               character_id <- String.to_integer(character_id),
               {:ok, _pid} <- Game.get_pid({state.instance_id, :character, character_id}),
               {:ok, {character, position, angle}} <-
                 Game.call(state.instance_id, :character, character_id, :get_position),
               # only keep characters visible to a radar
               true <- Position.in_disk(position, disk) do
            {disk, character, position, angle}
          else
            {:error, :process_not_found} ->
              Spatial.delete(found, state.instance_id)
              false

            _ ->
              false
          end
        end,
        on_timeout: :kill_task
      )
      |> Stream.filter(fn {atom, item} -> :ok == atom and item end)
      |> Stream.map(fn {:ok, val} -> val end)
      # only keep one of each object
      |> Stream.uniq_by(fn {_radar, character, _position, _angle} -> character.id end)
      # return a list of %{faction: , character_id: , position: }
      |> Stream.map(fn {_radar, character, position, angle} ->
        %{faction: character.owner.faction, character_id: character.id, position: position, angle: angle}
      end)
      |> Enum.to_list()

    {change, %{state | detected_objects: characters_in_radar}}
  end

  defp detect_changes({change, state}, prev_state) do
    prev_detected_characters_id = Enum.map(prev_state.detected_objects, fn object -> object.character_id end)
    new_object_in_radar? = Enum.any?(state.detected_objects, &(&1.character_id not in prev_detected_characters_id))

    # detect if new object entered into the radar
    change =
      if new_object_in_radar?,
        do: MapSet.put(change, :new_object_in_radar),
        else: change

    # no update when the radar was empty and it still is
    change =
      if Enum.empty?(prev_state.detected_objects) and Enum.empty?(state.detected_objects),
        do: change,
        else: MapSet.put(change, :update_object)

    {change, state}
  end

  defp filter_radar_by_visibility(state) do
    :maps.filter(
      fn system_id, radar ->
        contact = get_system_contact(state, system_id)

        is_same_faction = radar.faction_id == state.id
        has_max_visibility = contact.value == 5

        # TODO
        # ajouter les modificateurs contextuel
        # - en guerre -> -1
        # - allié -> +1

        is_same_faction or has_max_visibility
      end,
      state.all_radars
    )
  end
end
