defmodule Instance.Player.Player do
  use TypedStruct
  use Util.MakeEnumerable

  alias Instance.Player
  alias Instance.Character.Character
  alias Instance.StellarSystem.StellarSystem
  alias Instance.Character.Spy
  alias Instance.Character.Speaker

  @initial_stats_interval 5
  @delay_before_inactivity 1920

  @values_to_update [
    :dominion_rate,
    :max_systems,
    :max_dominions,
    :max_admirals,
    :max_spies,
    :max_speakers,
    :technology,
    :ideology,
    :credit
  ]

  @key_to_pipeline [
    technology: :player_technology,
    ideology: :player_ideology,
    credit: :player_credit
  ]

  def jason(),
    do: [
      except: [
        :instance_id,
        :registration_id,
        :connected_clients,
        :pending_notifications,
        :next_stats,
        :last_connection
      ]
    ]

  typedstruct enforce: true do
    field(:id, integer())
    field(:account_id, integer())
    field(:faction_id, integer())
    field(:faction, atom())
    field(:is_dead, boolean())
    field(:is_bankrupt, boolean())
    field(:is_active, boolean())
    field(:avatar, String.t())
    field(:name, String.t())
    field(:stellar_systems, [%Player.StellarSystem{}] | [])
    field(:dominions, [%Player.StellarSystem{}] | [])
    field(:characters, [%Player.Character{}] | [])
    field(:credit, %Core.DynamicValue{})
    field(:technology, %Core.DynamicValue{})
    field(:ideology, %Core.DynamicValue{})
    field(:patents, [atom()] | [])
    field(:doctrines, [atom()] | [])
    field(:policies, [atom()] | [])
    field(:character_deck, [%{}] | [])
    field(:max_policies, integer())
    field(:update_policies_count, integer())
    field(:policies_cooldown, %Core.CooldownValue{})
    field(:max_systems, %Core.Value{})
    field(:max_dominions, %Core.Value{})
    field(:max_admirals, %Core.Value{})
    field(:max_spies, %Core.Value{})
    field(:max_speakers, %Core.Value{})
    field(:dominion_rate, %Core.Value{})
    field(:transformed_system_count, integer())

    field(:instance_id, integer())
    field(:registration_id, integer())
    field(:connected_clients, integer())
    field(:pending_notifications, [%Notification.Notification{}])
    field(:next_stats, integer())
    field(:last_connection, %Core.DynamicValue{})
  end

  def new(%RC.Accounts.Profile{} = profile, faction, instance_id, registration_id) do
    c = Data.Querier.one(Data.Game.Constant, instance_id, :main)
    faction_key = String.to_existing_atom(faction.faction_ref)

    {:ok, character_id} = Game.call(instance_id, :character_market, :master, :get_next_character_id)
    character = Character.new_initial(character_id, faction_key, instance_id)

    last_connection =
      Core.DynamicValue.new(0)
      |> Core.DynamicValue.add(:misc, Core.ValuePart.new(:default, 1))

    {:ok, state} =
      %Player.Player{
        id: profile.id,
        account_id: profile.account_id,
        faction_id: faction.id,
        faction: faction_key,
        is_dead: false,
        is_bankrupt: false,
        is_active: true,
        avatar: profile.avatar,
        name: profile.name,
        stellar_systems: [],
        dominions: [],
        characters: [],
        credit: Core.DynamicValue.new(c.player_starting_credit),
        technology: Core.DynamicValue.new(c.player_starting_technology),
        ideology: Core.DynamicValue.new(c.player_starting_ideology),
        patents: [],
        doctrines: [],
        policies: [],
        character_deck: [],
        max_policies: 1,
        update_policies_count: 1,
        policies_cooldown: Core.CooldownValue.new(),
        max_systems: Core.Value.new(),
        max_dominions: Core.Value.new(),
        max_admirals: Core.Value.new(),
        max_spies: Core.Value.new(),
        max_speakers: Core.Value.new(),
        dominion_rate: Core.Value.new(),
        transformed_system_count: 0,
        instance_id: instance_id,
        registration_id: registration_id,
        connected_clients: 0,
        pending_notifications: [],
        next_stats: @initial_stats_interval,
        last_connection: last_connection
      }
      |> compute_bonus()
      |> hire_character({0, 0, 0}, character)

    state
  end

  def compute_next_tick_interval(%Player.Player{} = state) do
    c = Data.Querier.one(Data.Game.Constant, state.instance_id, :main)

    next_stats = c.player_stats_interval - state.next_stats
    next_policies = Core.CooldownValue.next_tick_interval(state.policies_cooldown)

    next_characters =
      Enum.map(state.character_deck, fn
        %{cooldown: nil} -> :never
        %{cooldown: cooldown} -> Core.CooldownValue.next_tick_interval(cooldown)
      end)

    Enum.min([next_stats | [next_policies | next_characters]])
  end

  # Action handling

  def update_client_status(%Player.Player{} = state, :connect),
    do: Map.update(state, :connected_clients, 0, &(&1 + 1))

  def update_client_status(%Player.Player{} = state, :disconnect),
    do: Map.update(state, :connected_clients, 0, &(&1 - 1))

  def store_notification(%Player.Player{} = state, notif),
    do: %{state | pending_notifications: [notif | state.pending_notifications]}

  def flush_notification(%Player.Player{} = state),
    do: {state.pending_notifications, %{state | pending_notifications: []}}

  def can_add_stellar_system(%Player.Player{} = state) do
    if length(state.stellar_systems) >= state.max_systems.value,
      do: {:error, :not_enough_system_slot},
      else: true
  end

  def can_remove_stellar_system(%Player.Player{} = state) do
    if length(state.stellar_systems) > 1,
      do: true,
      else: {:error, :cannot_remove_last_system}
  end

  def add_stellar_system(%Player.Player{} = state, %StellarSystem{} = new_system) do
    state =
      %{state | stellar_systems: [Player.StellarSystem.convert(new_system) | state.stellar_systems]}
      |> compute_bonus()

    {:ok, state}
  end

  def update_stellar_system(%Player.Player{} = state, %StellarSystem{} = new_system) do
    stellar_systems =
      Enum.map(state.stellar_systems, fn system ->
        if system.id == new_system.id,
          do: Player.StellarSystem.convert(new_system),
          else: system
      end)

    %{state | stellar_systems: stellar_systems}
    |> compute_bonus()
  end

  def remove_stellar_system(%Player.Player{} = state, system_id) do
    try do
      stellar_systems = Enum.reject(state.stellar_systems, fn s -> s.id == system_id end)

      if length(stellar_systems) == length(state.stellar_systems), do: throw(:unknown_system)

      state =
        if Enum.empty?(stellar_systems),
          do: %{state | is_dead: true},
          else: state

      state =
        %{state | stellar_systems: stellar_systems}
        |> compute_bonus()

      {:ok, state}
    catch
      error -> {:error, error}
    end
  end

  def can_add_dominion(%Player.Player{} = state) do
    if length(state.dominions) >= state.max_dominions.value,
      do: {:error, :not_enough_dominion_slot},
      else: true
  end

  def add_dominion(%Player.Player{} = state, %StellarSystem{} = new_system) do
    state =
      %{state | dominions: [Player.StellarSystem.convert(new_system) | state.dominions]}
      |> compute_bonus()

    {:ok, state}
  end

  def update_dominion(%Player.Player{} = state, %StellarSystem{} = new_system) do
    dominions =
      Enum.map(state.dominions, fn system ->
        if system.id == new_system.id,
          do: Player.StellarSystem.convert(new_system),
          else: system
      end)

    %{state | dominions: dominions}
    |> compute_bonus()
  end

  def remove_dominion(%Player.Player{} = state, system_id) do
    try do
      dominions = Enum.reject(state.dominions, fn s -> s.id == system_id end)

      if length(dominions) == length(state.dominions), do: throw(:unknown_system)

      state =
        %{state | dominions: dominions}
        |> compute_bonus()

      {:ok, state}
    catch
      error -> {:error, error}
    end
  end

  def can_transform_system(%Player.Player{} = state) do
    if transform_system_cost(state) >= state.ideology.value,
      do: {:error, :not_enough_ideology},
      else: true
  end

  def pay_transform_system(%Player.Player{} = state) do
    state = %{
      state
      | ideology: Core.DynamicValue.remove_value(state.ideology, transform_system_cost(state)),
        transformed_system_count: state.transformed_system_count + 1
    }

    {:ok, state}
  end

  def can_abandon_system(%Player.Player{} = state) do
    c = Data.Querier.one(Data.Game.Constant, state.instance_id, :main)
    if c.abandonment_cost >= state.ideology.value, do: {:error, :not_enough_ideology}, else: true
  end

  def pay_abandon_system(%Player.Player{} = state) do
    c = Data.Querier.one(Data.Game.Constant, state.instance_id, :main)
    state = %{state | ideology: Core.DynamicValue.remove_value(state.ideology, c.abandonment_cost)}
    {:ok, state}
  end

  def order_building(%Player.Player{} = state, system_id, type, production_data, virtual \\ false) do
    {_, _, prod_key, prod_level} = production_data

    try do
      constant = Data.Querier.one(Data.Game.Constant, state.instance_id, :main)
      building = Data.Querier.one(Data.Game.Building, state.instance_id, prod_key)
      building_level_info = Enum.find(building.levels, fn x -> x.level == prod_level end)
      system = Enum.find(state.stellar_systems, fn system -> system.id == system_id end)

      credit_cost =
        case type do
          "build" -> building_level_info.credit
          "repair" -> round(building_level_info.credit * constant.building_repairs_factor)
        end

      if system == nil, do: throw(:system_not_found)
      if state.is_bankrupt, do: throw(:player_is_bankrupt)
      if credit_cost > state.credit.value, do: throw(:not_enough_credit)

      if type == "build" do
        if building_level_info.patent != nil do
          unless Enum.any?(state.patents, fn patent -> patent == building_level_info.patent end),
            do: throw(:patent_not_unlocked)
        end
      end

      if virtual do
        {:ok, state}
      else
        credit = Core.DynamicValue.remove_value(state.credit, credit_cost)
        {:ok, %{state | credit: credit}}
      end
    catch
      error -> {:error, error}
    end
  end

  def order_ship(%Player.Player{} = state, system_id, production_data, virtual \\ false) do
    {character_id, _, prod_key, _} = production_data

    try do
      ship_data = Data.Querier.one(Data.Game.Ship, state.instance_id, prod_key)
      character = Enum.find(state.characters, fn character -> character.id == character_id end)
      system = Enum.find(state.stellar_systems, fn system -> system.id == system_id end)

      if ship_data == nil, do: throw(:ship_not_found)
      if system == nil, do: throw(:system_not_found)
      if character == nil, do: throw(:character_not_found)
      if character.on_sold, do: throw(:character_on_sold)
      if state.is_bankrupt, do: throw(:player_is_bankrupt)
      if ship_data.credit_cost > state.credit.value, do: throw(:not_enough_credit)
      if ship_data.technology_cost > state.technology.value, do: throw(:not_enough_technology)

      if ship_data.patent != nil do
        unless Enum.any?(state.patents, fn patent -> patent == ship_data.patent end),
          do: throw(:patent_not_unlocked)
      end

      has_ancestors_patents? =
        Data.Querier.all(Data.Game.Ship, state.instance_id)
        |> Enum.filter(fn s -> s.model == ship_data.model and s.unit_count < ship_data.unit_count end)
        |> Enum.all?(fn s -> s.patent in state.patents end)

      unless has_ancestors_patents?, do: throw(:ancestors_patents_not_unlocked)

      if virtual do
        {:ok, state}
      else
        credit = Core.DynamicValue.remove_value(state.credit, ship_data.credit_cost)
        technology = Core.DynamicValue.remove_value(state.technology, ship_data.technology_cost)
        {:ok, %{state | credit: credit, technology: technology}}
      end
    catch
      error -> {:error, error}
    end
  end

  def purchase_patent(%Player.Player{} = state, patent_key) do
    try do
      patent = Data.Querier.one(Data.Game.Patent, state.instance_id, patent_key)

      if patent == nil, do: throw(:unknown_patent)
      if Enum.any?(state.patents, fn p -> p == patent.key end), do: throw(:patent_already_purchased)

      if patent.ancestor != nil do
        unless Enum.any?(state.patents, fn p -> p == patent.ancestor end), do: throw(:patent_locked)
      end

      constant = Data.Querier.one(Data.Game.Constant, state.instance_id, :main)
      cost = patent.cost * (1 + length(state.patents) * constant.patent_level_price_increase)

      if cost > state.technology.value, do: throw(:not_enough_technology)

      # TODO: modificateur culturel du prix du patent

      {:ok,
       %{
         state
         | patents: state.patents ++ [patent.key],
           technology: Core.DynamicValue.remove_value(state.technology, cost)
       }}
    catch
      error -> {:error, error}
    end
  end

  def purchase_doctrine(%Player.Player{} = state, doctrine_key) do
    try do
      doctrine = Data.Querier.one(Data.Game.Doctrine, state.instance_id, doctrine_key)

      if doctrine == nil, do: throw(:unknown_doctrine)
      if Enum.any?(state.doctrines, fn d -> d == doctrine.key end), do: throw(:doctrine_already_purchased)

      if doctrine.ancestor != nil do
        unless Enum.any?(state.doctrines, fn p -> p == doctrine.ancestor end), do: throw(:doctrine_locked)
      end

      constant = Data.Querier.one(Data.Game.Constant, state.instance_id, :main)
      cost = doctrine.cost * (1 + length(state.doctrines) * constant.doctrine_level_price_increase)

      if cost > state.ideology.value, do: throw(:not_enough_ideology)

      # TODO: modificateur culturel du prix de la doctrine

      state = %{
        state
        | doctrines: state.doctrines ++ [doctrine.key],
          ideology: Core.DynamicValue.remove_value(state.ideology, cost)
      }

      {:ok, state}
    catch
      error -> {:error, error}
    end
  end

  def purchase_policy_slot(%Player.Player{} = state) do
    try do
      c = Data.Querier.one(Data.Game.Constant, state.instance_id, :main)
      cost = (:math.pow(2, state.max_policies - 1) |> round) * c.initial_policy_slot_cost
      cost = if cost > c.policy_slot_maximum_cost, do: c.policy_slot_maximum_cost, else: cost

      if cost > state.ideology.value, do: throw(:not_enough_ideology)

      state = %{
        state
        | max_policies: state.max_policies + 1,
          ideology: Core.DynamicValue.remove_value(state.ideology, cost)
      }

      {:ok, state}
    catch
      error -> {:error, error}
    end
  end

  def update_policies(%Player.Player{} = state, doctrines_key) do
    try do
      if length(doctrines_key) > state.max_policies, do: throw(:too_many_policies)
      if Core.CooldownValue.locked?(state.policies_cooldown), do: throw(:cooldown_not_unlock)

      Enum.each(doctrines_key, fn doctrine_key ->
        doctrine = Data.Querier.one(Data.Game.Doctrine, state.instance_id, doctrine_key)

        if doctrine == nil, do: throw(:unknown_doctrine)
        if not Enum.member?(state.doctrines, doctrine.key), do: throw(:unavailable_doctrine)
      end)

      check =
        %{state | policies: doctrines_key}
        |> compute_bonus()

      if length(check.stellar_systems) > check.max_systems.value, do: throw(:not_enough_system_slot)
      if length(check.dominions) > check.max_dominions.value, do: throw(:not_enough_dominion_slot)

      if Enum.count(check.characters, fn c -> c.type == :admiral end) > check.max_admirals.value,
        do: throw(:not_enough_admirals_slot)

      if Enum.count(check.characters, fn c -> c.type == :spy end) > check.max_spies.value,
        do: throw(:not_enough_spies_slot)

      if Enum.count(check.characters, fn c -> c.type == :speaker end) > check.max_speakers.value,
        do: throw(:not_enough_speakers_slot)

      c = Data.Querier.one(Data.Game.Constant, state.instance_id, :main)
      cooldown = c.initial_update_policies_cooldown + state.update_policies_count * c.update_policies_cooldown_factor

      state =
        %{
          state
          | policies: doctrines_key,
            update_policies_count: state.update_policies_count + 1,
            policies_cooldown: Core.CooldownValue.set(state.policies_cooldown, cooldown)
        }
        |> compute_bonus()

      system_bonuses = extract_bonus(state, [:stellar_system])
      character_bonuses = extract_bonus(state, [:character, :army, :spy, :speaker])

      {:ok, state, system_bonuses, character_bonuses}
    catch
      error -> {:error, error}
    end
  end

  def check_hire_character(%Player.Player{} = state, {credit, technology, ideology}) do
    try do
      constant = Data.Querier.one(Data.Game.Constant, state.instance_id, :main)

      if state.is_bankrupt, do: throw(:player_is_bankrupt)
      if state.credit.value < credit, do: throw(:not_enough_credit)
      if state.technology.value < technology, do: throw(:not_enough_technology)
      if state.ideology.value < ideology, do: throw(:not_enough_ideology)

      if length(state.character_deck) >= constant.max_character_in_deck,
        do: throw(:character_deck_full)

      :ok
    catch
      error -> {:error, error}
    end
  end

  def hire_character(%Player.Player{} = state, {credit, technology, ideology}, %Character{} = character) do
    case check_hire_character(state, {credit, technology, ideology}) do
      :ok ->
        state = %{
          state
          | credit: Core.DynamicValue.remove_value(state.credit, credit),
            technology: Core.DynamicValue.remove_value(state.technology, technology),
            ideology: Core.DynamicValue.remove_value(state.ideology, ideology),
            character_deck: [%{cooldown: nil, character: Character.hire(character, state)} | state.character_deck]
        }

        {:ok, state}

      {:error, error} ->
        {:error, error}
    end
  end

  def dismiss_character(%Player.Player{} = state, character_id) do
    try do
      character_cd = Enum.find(state.character_deck, fn %{character: c} -> c.id == character_id end)

      if character_cd == nil, do: throw(:unknown_character)

      character_deck = Enum.reject(state.character_deck, fn %{character: c} -> c.id == character_id end)

      {:ok, %{state | character_deck: character_deck}}
    catch
      error -> {:error, error}
    end
  end

  def transfer_character(%Player.Player{} = state, character_id) do
    try do
      character = Enum.find(state.characters, fn c -> c.id == character_id end)
      if character == nil, do: throw(:unknown_character)
      characters = Enum.reject(state.characters, fn c -> c.id == character_id end)
      {:ok, %{state | characters: characters}}
    catch
      error -> {:error, error}
    end
  end

  def activate_character(%Player.Player{} = state, character_id, mode, system_id) do
    try do
      # character with cooldown
      character_cd = Enum.find(state.character_deck, fn %{character: c} -> c.id == character_id end)
      system = Enum.find(state.stellar_systems, fn s -> s.id == system_id end)

      if character_cd == nil, do: throw(:unknown_character)
      if character_cd.character.on_sold, do: throw(:character_on_sold)

      if not is_nil(character_cd.cooldown) and Core.CooldownValue.locked?(character_cd.cooldown),
        do: throw(:locked_character)

      character = Map.get(character_cd, :character, nil)

      if system == nil, do: throw(:unknown_system)
      if system.siege != nil, do: throw(:no_character_activation_under_siege)

      if mode == :governor and system.governor != nil, do: throw(:no_multiple_governor)
      if not character_available_slots?(state, character.type), do: throw(:not_enough_character_slot)

      character = Character.activate(character, mode, system_id)
      character_deck = Enum.reject(state.character_deck, fn %{character: c} -> c.id == character_id end)
      characters = state.characters ++ [Player.Character.convert(character)]

      {:ok, %{state | character_deck: character_deck, characters: characters}, character}
    catch
      error -> {:error, error}
    end
  end

  def deactivate_character(%Player.Player{} = state, %Character{} = character) do
    try do
      if Enum.find(state.characters, fn c -> c.id == character.id end) == nil, do: throw(:unknown_character)

      if character.status == :governor do
        system =
          Enum.find(state.stellar_systems, fn s ->
            if s.governor == nil,
              do: false,
              else: s.id == character.system
          end)

        if system == nil, do: throw(:character_not_at_home)
        if system.siege != nil, do: throw(:no_character_deactivation_under_siege)
      end

      if character.status == :on_board do
        system = Enum.find(state.stellar_systems, fn s -> s.id == character.system end)
        dominion = Enum.find(state.dominions, fn d -> d.id == character.system end)

        if system == nil and dominion == nil, do: throw(:character_not_at_home)
        if system != nil and system.siege != nil, do: throw(:no_character_deactivation_under_siege)
        if dominion != nil and dominion.siege != nil, do: throw(:no_character_deactivation_under_siege)
        if character.action_status != :idle, do: throw(:character_must_be_idle)
        if character.type == :speaker and Speaker.locked?(character.speaker), do: throw(:speaker_must_be_at_rest)
        if character.on_sold, do: throw(:character_on_sold)

        if character.type == :spy and Spy.discovered?(character.spy.cover.value, character.instance_id),
          do: throw(:spy_must_be_undercover)
      end

      character = Character.deactivate(character)
      characters = Enum.reject(state.characters, fn c -> c.id == character.id end)

      constant = Data.Querier.one(Data.Game.Constant, state.instance_id, :main)
      cooldown = Core.CooldownValue.new(constant.character_deck_cooldown)
      character_deck = [state.character_deck, %{cooldown: cooldown, character: character}] |> List.flatten()

      {:ok, %{state | character_deck: character_deck, characters: characters}, character}
    catch
      error -> {:error, error}
    end
  end

  def assassinate_character(%Player.Player{} = state, %Character{} = character) do
    try do
      if Enum.find(state.characters, fn c -> c.id == character.id end) == nil, do: throw(:unknown_character)

      character = Character.deactivate(character)
      characters = Enum.reject(state.characters, fn c -> c.id == character.id end)

      {:ok, %{state | characters: characters}, character}
    catch
      error -> {:error, error}
    end
  end

  def convert_character(%Player.Player{} = state, %Character{} = character, character_id, system_id) do
    character =
      character
      |> Character.deactivate()
      |> Character.convert(character_id, state)
      |> Character.activate(:on_board, system_id)

    characters = [Player.Character.convert(character) | state.characters]

    {:ok, %{state | characters: characters}, character}
  end

  def update_character(%Player.Player{} = state, %Character{} = new_character) do
    characters =
      Enum.map(state.characters, fn character ->
        if character.id == new_character.id,
          do: Player.Character.convert(new_character),
          else: character
      end)

    %{state | characters: characters}
    |> compute_bonus()
  end

  def kill_character(%Player.Player{} = state, %Character{} = character) do
    characters = Enum.reject(state.characters, fn c -> c.id == character.id end)

    %{state | characters: characters}
    |> compute_bonus()
  end

  def add_credit(%Player.Player{} = state, amount) do
    credit = Core.DynamicValue.add_value(state.credit, amount)
    %{state | credit: credit}
  end

  def add_technology(%Player.Player{} = state, amount) do
    technology = Core.DynamicValue.add_value(state.technology, amount)
    %{state | technology: technology}
  end

  def add_ideology(%Player.Player{} = state, amount) do
    ideology = Core.DynamicValue.add_value(state.ideology, amount)
    %{state | ideology: ideology}
  end

  def own_character?(%Player.Player{} = state, character_id) do
    Enum.find(state.characters, fn c -> c.id == character_id end) != nil
  end

  def own_system?(%Player.Player{} = state, system_id) do
    Enum.find(state.stellar_systems, fn s -> s.id == system_id end) != nil
  end

  def own_dominion?(%Player.Player{} = state, system_id) do
    Enum.find(state.dominions, fn s -> s.id == system_id end) != nil
  end

  def available_system_slot?(%Player.Player{} = state) do
    length(state.stellar_systems) < state.max_systems.value
  end

  def available_dominion_slot?(%Player.Player{} = state) do
    length(state.dominions) < state.max_dominions.value
  end

  def get_stats(%Player.Player{} = state) do
    sum_governors_levels =
      state.characters
      |> Enum.filter(fn c -> c.status == :governor end)
      |> Enum.reduce(0, fn c, acc -> acc + c.level end)

    sum_agents_levels =
      state.characters
      |> Enum.filter(fn c -> c.status == :on_board end)
      |> Enum.reduce(0, fn c, acc -> acc + c.level end)

    sum_fleet_maintenance =
      state.characters
      |> Enum.filter(fn c -> c.status == :on_board and c.type == :admiral end)
      |> Enum.reduce(0, fn c, acc -> acc + c.army_maintenance end)

    population =
      Enum.reduce(state.stellar_systems, 0, fn s, acc -> acc + s.workforce end) +
        Enum.reduce(state.dominions, 0, fn d, acc -> acc + d.workforce end)

    points =
      state.credit.change +
        10 * state.technology.change +
        10 * state.ideology.change +
        8 * sum_governors_levels +
        15 * sum_agents_levels +
        1.1 * sum_fleet_maintenance +
        state.credit.value / 100_000 +
        state.technology.value / 10_000 +
        state.ideology.value / 10_000

    %{
      output_credit: state.credit.change,
      output_technology: state.technology.change,
      output_ideology: state.ideology.change,
      stored_credit: state.credit.value,
      total_systems: length(state.stellar_systems) + length(state.dominions),
      total_population: population,
      points: points,
      best_prod: get_max_output(state.stellar_systems, :production),
      best_credit: get_max_output(state.stellar_systems, :credit),
      best_technology: get_max_output(state.stellar_systems, :technology),
      best_ideology: get_max_output(state.stellar_systems, :ideology),
      best_workforce: get_max_output(state.stellar_systems, :workforce),
      instance_id: state.instance_id,
      registration_id: state.registration_id
    }
    |> Enum.reduce(%{}, fn {key, value}, acc -> Map.put(acc, key, Kernel.trunc(value)) end)
  end

  defp get_max_output(systems, type) do
    best = Enum.max_by(systems, fn s -> Map.get(s, type) end, fn -> nil end)
    if best == nil, do: 0, else: Map.get(best, type)
  end

  # Tick handling

  def next_tick(%Player.Player{} = state, elapsed_time) do
    {MapSet.new(), state}
    |> update_values(elapsed_time)
  end

  # Core functions

  # check for next stats update
  def update_values({change, %Player.Player{} = state}, elapsed_time) do
    c = Data.Querier.one(Data.Game.Constant, state.instance_id, :main)

    new_next_stats = state.next_stats + elapsed_time

    {change, state} =
      if new_next_stats >= c.player_stats_interval do
        {change |> MapSet.put(:make_stats), %{state | next_stats: 0}}
      else
        {change, %{state | next_stats: new_next_stats}}
      end

    # update dynamic values
    state =
      Enum.reduce([:technology, :ideology, :credit], state, fn key, acc ->
        next_state = Core.DynamicValue.next_tick(Map.get(acc, key), elapsed_time)
        Map.replace!(acc, key, next_state)
      end)

    {change, state} = detect_bankruptcy(state, change)

    # update cooldown values
    policies_cd = Core.CooldownValue.next_tick(state.policies_cooldown, elapsed_time)

    # update character_deck cooldowns
    {character_deck, change} =
      Enum.reduce(state.character_deck, {[], change}, fn
        %{cooldown: nil} = character, {deck, change} ->
          {[character | deck], change}

        character, {deck, change} ->
          cd = Core.CooldownValue.next_tick(character.cooldown, elapsed_time)

          change =
            if Core.CooldownValue.recently_unlocked?(character.cooldown, cd),
              do: MapSet.put(change, :player_update),
              else: change

          {[Map.put(character, :cooldown, cd) | deck], change}
      end)

    character_deck = Enum.reverse(character_deck)

    # check cooldown value change
    change =
      if Core.CooldownValue.recently_unlocked?(state.policies_cooldown, policies_cd),
        do: MapSet.put(change, :player_update),
        else: change

    # is_active value change
    last_connection =
      if state.connected_clients > 0,
        do: Core.DynamicValue.change_value(state.last_connection, 0),
        else: Core.DynamicValue.next_tick(state.last_connection, elapsed_time)

    is_active = last_connection.value < @delay_before_inactivity

    change =
      if state.is_active != is_active,
        do: change |> MapSet.put(:update_player_activity),
        else: change

    # state update
    {change,
     %{
       state
       | policies_cooldown: policies_cd,
         character_deck: character_deck,
         last_connection: last_connection,
         is_active: is_active
     }}
  end

  # Helper functions

  defp compute_bonus(%Player.Player{} = state) do
    bonuses =
      extract_bonus(state, [:player])
      |> Enum.map(fn data ->
        %{
          reason: data.reason,
          bonus: data.bonus,
          from: Data.Querier.one(Data.Game.BonusPipelineIn, state.instance_id, data.bonus.from),
          to: Data.Querier.one(Data.Game.BonusPipelineOut, state.instance_id, data.bonus.to)
        }
      end)
      |> Enum.filter(fn bonus_data -> bonus_data.to.to == :player end)

    # reset all bonus
    state =
      Enum.reduce(@values_to_update, state, fn key, acc ->
        if Util.Type.advanced_dynamic_value?(Map.get(acc, key)),
          do: Map.replace!(acc, key, Core.DynamicValue.new(Map.get(acc, key).value)),
          else: Map.replace!(acc, key, Core.Value.new())
      end)

    Core.Bonus.apply_bonuses(state, :player, bonuses)
  end

  def extract_bonus(%Player.Player{} = state, target) do
    constant = Data.Querier.one(Data.Game.Constant, state.instance_id, :main)

    # extract initial bonus
    initial_bonuses =
      if Enum.member?(target, :player) do
        [
          %{
            reason: {:misc, :initial_system},
            bonus: %Core.Bonus{from: :direct, value: 1, type: :add, to: :player_system}
          },
          %{
            reason: {:misc, :initial_dominion_rate},
            bonus: %Core.Bonus{from: :direct, value: 0.3, type: :add, to: :dominion_rate}
          }
        ]
      else
        []
      end

    # extract bonus from stellar system
    system_bonuses =
      if Enum.member?(target, :player) do
        Enum.flat_map(state.stellar_systems, fn system ->
          Enum.map(system, fn {key, value} ->
            if Enum.member?([:technology, :ideology, :credit], key) do
              bonus = %Core.Bonus{from: :direct, value: value, type: :add, to: @key_to_pipeline[key]}
              [%{reason: {:system, system.name}, bonus: bonus}]
            else
              []
            end
          end)
        end)
      else
        []
      end

    # extract bonus from dominions
    dominion_bonuses =
      if Enum.member?(target, :player) do
        Enum.flat_map(state.dominions, fn system ->
          Enum.map(system, fn {key, value} ->
            if Enum.member?([:technology, :ideology, :credit], key) do
              bonus = %Core.Bonus{from: :dominion_rate, value: value, type: :add, to: @key_to_pipeline[key]}
              [%{reason: {:dominion, system.name}, bonus: bonus}]
            else
              []
            end
          end)
        end)
      else
        []
      end

    # extract bonus from policies
    policy_bonuses =
      Enum.reduce(state.policies, [], fn doctrine_key, acc ->
        doctrine = Data.Querier.one(Data.Game.Doctrine, state.instance_id, doctrine_key)

        Enum.reduce(doctrine.bonus, acc, fn bonus, acc ->
          to = Data.Querier.one(Data.Game.BonusPipelineOut, state.instance_id, bonus.to)

          if Enum.member?(target, to.to),
            do: [%{reason: {:doctrine, doctrine.key}, bonus: bonus} | acc],
            else: acc
        end)
      end)

    # extract bonus from factions traditions
    faction_data = Data.Querier.one(Data.Game.Faction, state.instance_id, state.faction)

    faction_bonuses =
      Enum.reduce(faction_data.traditions, [], fn %{key: key, bonus: bonus}, acc ->
        to = Data.Querier.one(Data.Game.BonusPipelineOut, state.instance_id, bonus.to)

        if Enum.member?(target, to.to),
          do: [%{reason: {:tradition, key}, bonus: bonus} | acc],
          else: acc
      end)

    # extract character wages
    character_wages =
      if Enum.member?(target, :player) do
        Enum.map(state.characters, fn character ->
          wages = -constant.character_level_wages * character.level
          bonus = %Core.Bonus{from: :direct_last, value: wages, type: :add, to: :player_credit}
          %{reason: {:character_wages, character.name}, bonus: bonus}
        end)
      else
        []
      end

    # extract fleet maintenance
    fleet_maintenance =
      if Enum.member?(target, :player) do
        admiral_with_ships =
          Enum.filter(state.characters, fn c ->
            c.type == :admiral and c.status == :on_board and c.army_maintenance > 0
          end)

        Enum.map(admiral_with_ships, fn character ->
          bonus = %Core.Bonus{from: :direct_last, value: -character.army_maintenance, type: :add, to: :player_credit}
          %{reason: {:fleet_maintenance, character.name}, bonus: bonus}
        end)
      else
        []
      end

    List.flatten([
      initial_bonuses,
      system_bonuses,
      dominion_bonuses,
      policy_bonuses,
      character_wages,
      fleet_maintenance,
      faction_bonuses
    ])
  end

  def character_available_slots?(%Player.Player{} = state, character_type) do
    character_count = Enum.count(state.characters, fn c -> c.type == character_type end)

    case character_type do
      :admiral -> character_count < state.max_admirals.value
      :spy -> character_count < state.max_spies.value
      :speaker -> character_count < state.max_speakers.value
    end
  end

  defp detect_bankruptcy(%Player.Player{} = state, change) do
    is_bankrupt = state.credit.value <= 0 and state.credit.change < 0

    cond do
      # just became bankrupt
      is_bankrupt and not state.is_bankrupt ->
        %{state | is_bankrupt: true}
        |> bankruptcy_update_characters(change)

      # not bankrupt anymore
      not is_bankrupt and state.is_bankrupt ->
        %{state | is_bankrupt: false}
        |> bankruptcy_update_characters(change)

      # still not bankrupt or was already bankrupt
      is_bankrupt == state.is_bankrupt ->
        {change, state}
    end
  end

  defp bankruptcy_update_characters(state, change) do
    state =
      state.characters
      |> Enum.reduce(state, fn character, state_acc ->
        case Game.call(state.instance_id, :character, character.id, {:update_strike, state.is_bankrupt}) do
          {:ok, character} ->
            update_character(state_acc, character)

          {:error, _reason} ->
            state_acc
        end
      end)

    {MapSet.put(change, :player_update), state}
  end

  defp transform_system_cost(%Player.Player{} = state) do
    c = Data.Querier.one(Data.Game.Constant, state.instance_id, :main)
    c.transform_initial_cost + state.transformed_system_count * c.transform_additional_cost
  end
end
