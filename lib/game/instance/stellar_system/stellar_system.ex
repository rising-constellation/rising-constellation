defmodule Instance.StellarSystem.StellarSystem do
  use TypedStruct
  use Util.MakeEnumerable

  alias Spatial.Position
  alias Instance.StellarSystem
  alias Instance.StellarSystem.ProductionQueue

  @base_radar 1.0
  @ai_next_action_unit_days 50
  @max_remove_contact 25_000
  @limited_penalty_fields [:sys_production]
  @standard_penalty_fields [
    :sys_production,
    :sys_credit,
    :sys_technology,
    :sys_ideology,
    :sys_defense,
    :sys_ci,
    :sys_remove_contact,
    :sys_fighter_lvl,
    :sys_corvette_lvl,
    :sys_frigate_lvl,
    :sys_capital_lvl
  ]

  def jason(),
    do: [
      except: [:instance_id, :capital?, :bonuses, :raid_potential, :ai_profile, :ai_next_action, :happiness_penalties]
    ]

  typedstruct enforce: true do
    field(:id, integer())
    field(:position, %Position{})
    field(:sector_id, integer())
    field(:name, String.t())
    field(:type, atom())
    field(:status, :uninhabitable | :uninhabited | :inhabited_neutral | :inhabited_dominion | :inhabited_player)
    field(:owner, %StellarSystem.Player{} | nil)
    field(:governor, %StellarSystem.Character{} | nil)
    field(:characters, [%StellarSystem.Character{}] | [], default: [])
    field(:bodies, [%StellarSystem.StellarBody{}])
    field(:queue, %StellarSystem.ProductionQueue{})
    field(:population, %Core.DynamicValue{}, default: Core.DynamicValue.new(0.0))
    field(:workforce, integer(), default: 0)
    field(:used_workforce, integer(), default: 0)
    field(:population_status, atom(), default: :normal)
    field(:population_class, atom() | nil)
    field(:habitation, %Core.Value{}, default: Core.Value.new())
    field(:production, %Core.Value{}, default: Core.Value.new())
    field(:technology, %Core.Value{}, default: Core.Value.new())
    field(:ideology, %Core.Value{}, default: Core.Value.new())
    field(:credit, %Core.Value{}, default: Core.Value.new())
    field(:happiness, %Core.Value{}, default: Core.Value.new())
    field(:mobility, %Core.Value{}, default: Core.Value.new())
    field(:counter_intelligence, %Core.Value{}, default: Core.Value.new())
    field(:defense, %Core.Value{}, default: Core.Value.new())
    field(:remove_contact, %Core.DynamicValue{})
    field(:radar, %Core.Value{}, default: Core.Value.new())
    field(:fighter_lvl, %Core.Value{}, default: Core.Value.new())
    field(:corvette_lvl, %Core.Value{}, default: Core.Value.new())
    field(:frigate_lvl, %Core.Value{}, default: Core.Value.new())
    field(:capital_lvl, %Core.Value{}, default: Core.Value.new())
    field(:siege, %StellarSystem.Siege{} | nil)

    field(:instance_id, integer())
    field(:capital?, boolean())
    field(:bonuses, %{}, default: %{})
    field(:raid_potential, %Core.DynamicValue{})
    field(:ai_profile, atom())
    field(:ai_next_action, %Core.DynamicValue{})
    field(:happiness_penalties, [%{}])
  end

  def new(system, sector_id, instance_id) do
    c = Data.Querier.one(Data.Game.Constant, instance_id, :main)

    name = Data.Picker.random("place", instance_id)
    type = String.to_existing_atom(system["type"])

    # add random starting position variation
    # purpose: not showing that stellar systems are grid-based
    position = %Position{
      x: system["position"]["x"] + Game.call(instance_id, :rand, :master, {:uniform, 50}) / 100 - 0.5,
      y: system["position"]["y"] + Game.call(instance_id, :rand, :master, {:uniform, 50}) / 100 - 0.5
    }

    # generate bodies
    system_data = Data.Querier.one(Data.Game.StellarSystem, instance_id, type)

    bodies =
      0..Game.call(instance_id, :rand, :master, {:random, system_data.gen_body_number})
      |> Enum.filter(fn i -> i != 0 end)
      |> Enum.map(fn i -> StellarSystem.StellarBody.new(i, name, instance_id, :primary) end)

    # generate status
    status =
      if Enum.find_value(bodies, false, fn x -> x.type == :habitable_planet or x.type == :sterile_planet end) do
        if Game.call(instance_id, :rand, :master, {:uniform}) < c.system_neutral_ratio,
          do: :inhabited_neutral,
          else: :uninhabited
      else
        :uninhabitable
      end

    raid_potential =
      Core.DynamicValue.new(100.0)
      |> Core.DynamicValue.add(:misc, Core.ValuePart.new(:default, c.system_raid_potential_growth))

    ai_next_action =
      Core.DynamicValue.new(Game.call(instance_id, :rand, :master, {:uniform, 0, @ai_next_action_unit_days}))
      |> Core.DynamicValue.add(:misc, Core.ValuePart.new(:default, 1))

    remove_contact =
      Game.call(instance_id, :rand, :master, {:uniform, @max_remove_contact})
      |> Core.DynamicValue.new()

    # choose dominion profile
    ai_profile = Game.call(instance_id, :rand, :master, {:random, SystemAI.Helper.profiles()})

    state = %StellarSystem.StellarSystem{
      id: system["key"],
      position: position,
      sector_id: sector_id,
      name: name,
      type: type,
      status: status,
      owner: nil,
      governor: nil,
      bodies: bodies,
      queue: StellarSystem.ProductionQueue.new(),
      population_class: nil,
      remove_contact: remove_contact,
      siege: nil,
      instance_id: instance_id,
      capital?: false,
      raid_potential: raid_potential,
      ai_profile: ai_profile,
      ai_next_action: ai_next_action,
      happiness_penalties: []
    }

    # open system in case of neutral autonomous system
    if state.status == :inhabited_neutral,
      do: open_system(state),
      else: state
  end

  def compute_next_tick_interval(state) do
    remaining_production_time = ProductionQueue.get_next_action_remaining_time(state)

    remaining_until_next_pop =
      if state.population.change != 0,
        do: 2,
        else: :never

    Enum.min([remaining_production_time, remaining_until_next_pop])
  end

  # Action handling

  def claim(state, player, is_initial_system, is_dominion) do
    former_faction_id =
      if is_nil(state.owner),
        do: nil,
        else: state.owner.faction_id

    state =
      if is_initial_system,
        do: transform_to_starter_system(state),
        else: state

    state =
      if state.status in [:uninhabitable, :uninhabited],
        do: open_system(state),
        else: state

    status =
      if is_dominion,
        do: :inhabited_dominion,
        else: :inhabited_player

    state = %{state | capital?: is_initial_system, status: status, owner: Instance.StellarSystem.Player.convert(player)}

    {_, _, state} = compute_bonus({MapSet.new(), [], state})

    if former_faction_id != state.owner.faction_id,
      do: {:radar_update, state},
      else: {:no_radar_update, state}
  end

  def abandon(state) do
    {_, _, state} =
      %{state | capital?: false, status: :inhabited_neutral, owner: nil}
      |> update_bonuses(:player, [])

    {:radar_update, state}
  end

  def besiege(state, type, duration, character_id) do
    {_, _, state} =
      {MapSet.new(), [], %{state | siege: StellarSystem.Siege.new(type, duration, character_id)}}
      |> compute_bonus()

    state
  end

  def release_siege(state) do
    {_, _, state} =
      {MapSet.new(), [], %{state | siege: nil}}
      |> compute_bonus()

    state
  end

  def raid(state, lost_population_chances, building_count_to_damage) do
    c = Data.Querier.one(Data.Game.Constant, state.instance_id, :main)

    # compute population lost
    lost_population = state.population.value * lost_population_chances
    population = Core.DynamicValue.new(state.population.value - lost_population)

    # compute raid_potential reduction
    raid_potential_copy = state.raid_potential.value

    lost_raid_potential =
      if state.raid_potential.value < c.raid_potential_impact,
        do: state.raid_potential.value,
        else: c.raid_potential_impact

    raid_potential = Core.DynamicValue.remove_value(state.raid_potential, lost_raid_potential)

    # damage buildings
    {bodies, damaged_building} =
      Enum.reduce(1..building_count_to_damage, {state.bodies, 0}, fn _i, {bodies, damaged_building} ->
        case damage_tile(bodies, state.instance_id) do
          {:damaged, bodies} -> {bodies, damaged_building + 1}
          {:nothing_to_damage, bodies} -> {bodies, damaged_building}
        end
      end)

    {_, _, state} =
      {MapSet.new(), [], %{state | bodies: bodies, population: population, raid_potential: raid_potential}}
      |> compute_bonus()

    {state,
     %{population_lost: lost_population, raid_potential: raid_potential_copy, damaged_building: damaged_building}}
  end

  def order_building_production(state, production_data) do
    {target_id, tile_id, prod_key, prod_level} = production_data

    try do
      body = extract_body(state.bodies, target_id)

      body_data = Data.Querier.one(Data.Game.StellarBody, state.instance_id, body.type)
      building_data = Data.Querier.one(Data.Game.Building, state.instance_id, prod_key)
      building_level_info = Enum.find(building_data.levels, fn x -> x.level == prod_level end)

      if state.siege != nil, do: throw(:no_production_under_siege)
      if body_data.biome != building_data.biome, do: throw(:wrong_biome)
      if building_level_info == nil, do: throw(:unknown_level)

      tile = extract_tile(state.bodies, target_id, tile_id)
      first_tile = extract_tile(state.bodies, target_id, 1)

      if tile.construction_status != :none, do: throw(:building_already_under_construction)
      if tile == nil, do: throw(:unknown_tile)

      if tile.building_status == :empty do
        if tile.type == :infrastructure do
          if building_data.type != :infrastructure, do: throw(:wrong_building_type)
        else
          if building_data.type == :infrastructure, do: throw(:wrong_building_type)
        end

        if body_data.biome != :orbital and tile.id > 1 do
          if first_tile.building_status == :empty, do: throw(:no_building_without_infra)
        end
      else
        if tile.building_key != prod_key, do: throw(:tile_has_other_building)
        if tile.building_level == prod_level, do: throw(:building_already_exists)
        if tile.building_level + 1 > prod_level, do: throw(:cannot_downgrade_building)
        if tile.building_level + 1 < prod_level, do: throw(:cannot_upgrade_by_over_one)

        if body_data.biome != :orbital do
          if tile.id != 1 do
            if first_tile.building_level < prod_level, do: throw(:not_upper_than_infra)
          end
        end
      end

      if prod_level == 1 do
        case building_data.limitation do
          :unique_body ->
            Enum.each(flatten_bodies(state.bodies), fn body ->
              if body.uid == target_id do
                Enum.each(body.tiles, fn tile ->
                  if tile.building_key == prod_key, do: throw(:already_one_on_body)
                end)
              end
            end)

          :unique_system ->
            Enum.each(flatten_bodies(state.bodies), fn body ->
              Enum.each(body.tiles, fn tile ->
                if tile.building_key == prod_key, do: throw(:already_one_on_system)
              end)
            end)

          _ ->
            nil
        end
      end

      # set tile construction status
      state = %{
        state
        | bodies:
            update_tile(state.bodies, target_id, tile_id, fn tile ->
              StellarSystem.Tile.plan_building(tile, prod_key)
            end)
      }

      # order construction
      queue =
        StellarSystem.ProductionQueue.queue_item(
          state.queue,
          :building,
          {
            target_id,
            tile_id,
            prod_key,
            prod_level,
            building_level_info.production
          }
        )

      state = %{state | queue: queue}
      state = compute_used_workforce(state)

      {:ok, state}
    catch
      reason -> {:error, reason}
    end
  end

  def can_order_ship(state, production_data, character) do
    {_character_id, _tile_id, prod_key, _prod_level} = production_data

    try do
      ship_data = Data.Querier.one(Data.Game.Ship, state.instance_id, prod_key)

      if state.siege != nil, do: throw(:no_production_under_siege)
      if character.system != state.id, do: throw(:character_not_at_home)

      if ship_data.shipyard != nil do
        has_shipyard =
          Enum.any?(flatten_bodies(state.bodies), fn body ->
            Enum.any?(body.tiles, fn tile ->
              tile.building_key == ship_data.shipyard and tile.building_status == :built
            end)
          end)

        unless has_shipyard, do: throw(:shipyard_not_found)
      end

      {:ok, state}
    catch
      reason -> {:error, reason}
    end
  end

  def order_ship_production(state, production_data, character) do
    {character_id, tile_id, prod_key, prod_level} = production_data

    case can_order_ship(state, production_data, character) do
      # order construction
      {:ok, _} ->
        ship_data = Data.Querier.one(Data.Game.Ship, state.instance_id, prod_key)

        queue =
          StellarSystem.ProductionQueue.queue_item(
            state.queue,
            :ship,
            {
              character_id,
              tile_id,
              prod_key,
              prod_level,
              ship_data.production
            }
          )

        {:ok, %{state | queue: queue}}

      error ->
        error
    end
  end

  def order_building_repairs(state, production_data) do
    {target_id, tile_id, _, _} = production_data

    try do
      if state.siege != nil, do: throw(:no_production_under_siege)

      tile = extract_tile(state.bodies, target_id, tile_id)

      if tile == nil, do: throw(:unknown_tile)
      if tile.construction_status != :none, do: throw(:no_repair_during_construction)
      if tile.building_status != :damaged, do: throw(:no_undamaged_repairs)

      constant = Data.Querier.one(Data.Game.Constant, state.instance_id, :main)
      building_data = Data.Querier.one(Data.Game.Building, state.instance_id, tile.building_key)
      building_level_info = Enum.find(building_data.levels, fn x -> x.level == tile.building_level end)

      # set tile construction status
      state = %{
        state
        | bodies:
            update_tile(state.bodies, target_id, tile_id, fn tile ->
              StellarSystem.Tile.plan_repair_building(tile)
            end)
      }

      # order construction
      queue =
        StellarSystem.ProductionQueue.queue_item(
          state.queue,
          :building_repairs,
          {
            target_id,
            tile_id,
            tile.building_key,
            tile.building_level,
            round(building_level_info.production * constant.building_repairs_factor)
          }
        )

      state = %{state | queue: queue}
      state = compute_used_workforce(state)

      {:ok, state}
    catch
      reason -> {:error, reason}
    end
  end

  def remove_building(state, production_data) do
    {target_id, tile_id} = production_data

    try do
      body = extract_body(state.bodies, target_id)
      tile = extract_tile(state.bodies, target_id, tile_id)

      if state.siege != nil, do: throw(:no_removal_under_siege)
      if body == nil, do: throw(:unknown_body)
      if tile == nil, do: throw(:unknown_tile)
      if tile.construction_status != :none, do: throw(:no_removal_under_construction)
      if tile.type == :infrastructure, do: throw(:infrastructure_are_not_removable)

      # set tile construction status
      state = %{
        state
        | bodies:
            update_tile(state.bodies, target_id, tile_id, fn tile ->
              StellarSystem.Tile.remove_building(tile)
            end)
      }

      {change, notifs, data} =
        {MapSet.new(), [], state}
        |> compute_bonus()

      {:ok, change, notifs, data}
    catch
      reason -> {:error, reason}
    end
  end

  def cancel_ordered_ships(state, character_id) do
    %{state | queue: StellarSystem.ProductionQueue.reject_items(state.queue, character_id, :ship)}
  end

  def cancel_production(state, production_id) do
    try do
      if state.siege != nil, do: throw(:no_removal_under_siege)

      case StellarSystem.ProductionQueue.unqueue_item(state.queue, production_id) do
        {:ok, item, queue} ->
          case item.type do
            :ship ->
              ship_data = Data.Querier.one(Data.Game.Ship, state.instance_id, item.prod_key)
              {:ok, item.type, item, ship_data.credit_cost, ship_data.technology_cost, %{state | queue: queue}}

            type ->
              constant = Data.Querier.one(Data.Game.Constant, state.instance_id, :main)
              building = Data.Querier.one(Data.Game.Building, state.instance_id, item.prod_key)
              building_level_info = Enum.find(building.levels, fn x -> x.level == item.prod_level end)

              credit_cost =
                case type do
                  :building -> building_level_info.credit
                  :building_repairs -> round(building_level_info.credit * constant.building_repairs_factor)
                end

              # set tile construction status
              state = %{
                state
                | queue: queue,
                  bodies:
                    update_tile(state.bodies, item.target_id, item.tile_id, fn tile ->
                      case type do
                        :building -> StellarSystem.Tile.unplan_building(tile)
                        :building_repairs -> StellarSystem.Tile.unplan_repair_building(tile)
                      end
                    end)
              }

              state = compute_used_workforce(state)
              {:ok, item.type, credit_cost, state}
          end

        {:error, error} ->
          {:error, error}
      end
    catch
      reason -> {:error, reason}
    end
  end

  def push_character(state, character, :governor) do
    bonuses = Instance.Character.Character.extract_bonus(character, [:stellar_system])

    {_, _, state} =
      %{state | governor: Instance.StellarSystem.Character.convert(character)}
      |> update_bonuses(:character, bonuses)

    {:ok, state}
  end

  def push_character(state, character, :on_board) do
    characters = List.flatten(state.characters, [Instance.StellarSystem.Character.convert(character)])
    {:ok, %{state | characters: characters}}
  end

  def update_character(state, character) do
    characters =
      Enum.map(state.characters, fn c ->
        if c.id == character.id,
          do: Instance.StellarSystem.Character.convert(character),
          else: c
      end)

    {:ok, %{state | characters: characters}}
  end

  def remove_character(state, _character, :governor) do
    {_, _, state} =
      %{state | governor: nil}
      |> update_bonuses(:character, [])

    {:ok, state}
  end

  def remove_character(state, character, :on_board) do
    characters = Enum.reject(state.characters, fn c -> c.id == character.id end)
    {:ok, %{state | characters: characters}}
  end

  def add_happiness_penalty(state, reason, value) do
    state = %{state | happiness_penalties: [%{reason: reason, value: value} | state.happiness_penalties]}

    {MapSet.new(), [], state}
    |> compute_bonus()
  end

  def update_bonuses(state, from, bonuses) do
    {MapSet.new(), [], %{state | bonuses: Map.put(state.bonuses, from, bonuses)}}
    |> compute_bonus()
  end

  # Tick handling

  def next_tick(state, elapsed_time) do
    {MapSet.new(), [], state}
    |> update_raid_potential(elapsed_time)
    |> update_siege(elapsed_time)
    |> update_happiness_penalties(elapsed_time)
    |> update_population(elapsed_time)
    |> resolve_production(elapsed_time)
    |> auto_actions(elapsed_time)
    |> update_remove_contact(elapsed_time)
  end

  # Core functions

  defp update_remove_contact({change, notifs, state}, elapsed_time) when state.remove_contact.change > 0 do
    remove_contact = Core.DynamicValue.next_tick(state.remove_contact, elapsed_time)

    if remove_contact.value > @max_remove_contact do
      remove_contact = Core.DynamicValue.change_value(remove_contact, 0)
      change = MapSet.put(change, :remove_contact)

      {change, notifs, %{state | remove_contact: remove_contact}}
    else
      {change, notifs, %{state | remove_contact: remove_contact}}
    end
  end

  defp update_remove_contact({change, notifs, state}, _elapsed_time),
    do: {change, notifs, state}

  defp auto_actions({change, notifs, state}, elapsed_time)
       when state.status == :inhabited_neutral or state.status == :inhabited_dominion do
    ai_next_action = Core.DynamicValue.next_tick(state.ai_next_action, elapsed_time)

    if ai_next_action.value >= @ai_next_action_unit_days do
      ai_next_action = Core.DynamicValue.change_value(ai_next_action, 0.0)
      system_value = compute_value(state)

      case SystemAI.do_action(state, system_value) do
        {:ok, updated_state} ->
          {change, notifs, %{updated_state | ai_next_action: ai_next_action}}

        {:error, _reason} ->
          # no update
          {change, notifs, %{state | ai_next_action: ai_next_action}}
      end
    else
      {change, notifs, %{state | ai_next_action: ai_next_action}}
    end
  end

  defp auto_actions({change, notifs, state}, _elapsed_time),
    do: {change, notifs, state}

  defp update_raid_potential({change, notifs, state}, elapsed_time) do
    if state.raid_potential.value < 100 do
      raid_potential = Core.DynamicValue.next_tick(state.raid_potential, elapsed_time)

      raid_potential =
        if raid_potential.value >= 100,
          do: Core.DynamicValue.change_value(raid_potential, 100),
          else: raid_potential

      {change, notifs, %{state | raid_potential: raid_potential}}
    else
      {change, notifs, state}
    end
  end

  defp update_siege({change, notifs, state}, elapsed_time) do
    if state.siege do
      {status, siege} = StellarSystem.Siege.next_tick(state.siege, elapsed_time)

      state =
        case status do
          :keep_siege -> %{state | siege: siege}
          :release_siege -> %{state | siege: nil}
        end

      {change, notifs, state}
    else
      {change, notifs, state}
    end
  end

  defp update_happiness_penalties({change, notifs, state}, elapsed_time) when length(state.happiness_penalties) > 0 do
    c = Data.Querier.one(Data.Game.Constant, state.instance_id, :main)

    happiness_penalties =
      state.happiness_penalties
      |> Enum.map(fn penalty ->
        %{penalty | value: penalty.value - elapsed_time * c.happiness_penalty_reduction_factor}
      end)
      |> Enum.filter(fn penalty -> penalty.value > 0 end)

    state = %{state | happiness_penalties: happiness_penalties}

    {change, notifs, state}
    |> compute_bonus(:without_player_update)
  end

  defp update_happiness_penalties({change, notifs, state}, _elapsed_time),
    do: {change, notifs, state}

  defp resolve_production({change, notifs, state}, elapsed_time) do
    add_production({change, notifs, state}, state.production.value * elapsed_time)
  end

  defp add_production({change, notifs, state}, production) do
    case StellarSystem.ProductionQueue.add_production(state.queue, production) do
      {queue, rest, item} ->
        case item.type do
          :ship ->
            classes = %{fighter: :fighter_lvl, corvette: :corvette_lvl, frigate: :frigate_lvl, capital: :capital_lvl}
            ship_data = Data.Querier.one(Data.Game.Ship, state.instance_id, item.prod_key)

            initial_xp =
              if not is_nil(Map.get(classes, ship_data.class)),
                do: Map.get(state, Map.get(classes, ship_data.class)).value,
                else: 0

            change =
              change
              |> MapSet.put(:player_update)
              |> MapSet.put({:ship_built, item, initial_xp})

            notifs = [Notification.Sound.new(:ship_finished) | notifs]
            {change, notifs, %{state | queue: queue}}

          type ->
            updated_bodies =
              update_tile(state.bodies, item.target_id, item.tile_id, fn tile ->
                case type do
                  :building -> StellarSystem.Tile.put_building(tile)
                  :building_repairs -> StellarSystem.Tile.repair_building(tile)
                end
              end)

            notifs = [Notification.Sound.new(:building_finished) | notifs]
            state = %{state | bodies: updated_bodies, queue: queue}

            {change, notifs, state}
            |> compute_bonus()
            |> add_production(rest)
        end

      queue ->
        {change, notifs, %{state | queue: queue}}
    end
  end

  defp update_population({change, notifs, state}, elapsed_time) do
    previous_workforce = state.workforce
    {updated_population, updated_growth} = population_next_tick(state, elapsed_time)

    population =
      updated_population
      |> Core.DynamicValue.new()
      |> Core.DynamicValue.add(:misc, Core.ValuePart.new(:standard_growth, updated_growth))

    state = %{state | population: population, workforce: floor(population.value)}

    if previous_workforce != state.workforce do
      state = compute_local_population(state)
      {change, notifs, state} = compute_bonus({change, notifs, state})
      state = compute_local_population(state)
      {change, notifs, state} = compute_bonus({change, notifs, state})
      {MapSet.put(change, :player_update), notifs, state}
    else
      {change, notifs, state}
    end
  end

  defp population_next_tick(state, elapsed_time) do
    c = Data.Querier.one(Data.Game.Constant, state.instance_id, :main)

    habitation = state.habitation.value
    population = state.population.value
    happiness = state.happiness.value

    growth =
      cond do
        happiness < -10 ->
          -0.002

        happiness < 0 ->
          -0.001

        true ->
          # base_growth
          base_growth = c.system_base_growth

          # happiness growth factor
          useful_happiness = Enum.min([happiness, 25])
          happiness_factor = useful_happiness * 0.002

          # habitation growth factor [-1, 1]
          habitation_target = habitation + 0.75
          habitation_factor = (habitation_target - population) * 0.1
          habitation_factor = Enum.min([habitation_factor, 1])

          # global population growth factor [0, 1]
          # 0 pop -> no penalty
          # 120+ pop -> biggest penalty
          pop_factor = (1 - Enum.min([population, 120]) / 120) * 0.8 + 0.2

          # final growth
          (base_growth + happiness_factor) * habitation_factor * pop_factor
      end

    new_population = population + growth * elapsed_time

    if new_population < 0,
      do: {0, 0},
      else: {new_population, growth}
  end

  defp compute_bonus({change, notifs, state}, updates \\ :with_player_update) do
    former_happiness = state.happiness.value
    former_population_status = state.population_status
    former_population_class = state.population_class
    former_radar = state.radar.value

    # clear out the state for computed values
    state =
      state
      |> reset_system_value_fields()
      |> compute_used_workforce()

    # fetch relevant data from Data Module
    buildings_data = Data.Querier.all(Data.Game.Building, state.instance_id)
    buildings = extract_buildings(state.bodies)

    # collect all the building bonus
    building_bonuses =
      Enum.flat_map(buildings, fn building ->
        building_data = Enum.find(buildings_data, &(&1.key == building.key))
        building_level_data = Enum.find(building_data.levels, &(&1.level == building.level))

        Enum.map(building_level_data.bonus, fn bonus ->
          %{
            metadata: %{stellar_body: building.stellar_body},
            reason: {:building, building.key},
            bonus: bonus,
            from: Data.Querier.one(Data.Game.BonusPipelineIn, state.instance_id, bonus.from),
            to: Data.Querier.one(Data.Game.BonusPipelineOut, state.instance_id, bonus.to)
          }
        end)
      end)

    # collect other bonuses
    initial_bonuses =
      collect_initial_bonuses(state)
      |> Enum.map(fn data -> expand_bonus(data, state) end)

    happiness_bonuses =
      collect_happiness_penalties(state)
      |> Enum.map(fn data -> expand_bonus(data, state) end)

    outside_bonuses =
      Enum.flat_map(state.bonuses, fn {_, bonuses} -> bonuses end)
      |> Enum.map(fn data -> expand_bonus(data, state) end)

    # apply bonus to state
    bonuses = List.flatten([building_bonuses, initial_bonuses, happiness_bonuses, outside_bonuses])
    state = Core.Bonus.apply_bonuses(state, :stellar_system, bonuses)

    # check population_status
    {state, ps_notifs, pop_status} = update_population_status(former_population_status, former_happiness, state)

    # check population_status
    state = update_population_class(state)

    # check penalties
    siege_penalty = if state.siege != nil, do: 1, else: 0

    workforce_penalty =
      if state.used_workforce > state.workforce,
        do: 1 - state.workforce / state.used_workforce,
        else: 0

    state =
      state
      |> apply_penalties(:siege, siege_penalty)
      |> apply_penalties(:workforce, workforce_penalty)
      |> apply_penalties(:uprising, pop_status.penalty)

    # check any radar update
    change =
      if former_radar != state.radar.value,
        do: MapSet.put(change, :radar_update),
        else: change

    # check new pop class
    change =
      if former_population_class != state.population_class,
        do: change |> MapSet.put(:population_class_update) |> MapSet.put(:player_update),
        else: change

    # update player if needed
    change =
      if updates === :with_player_update,
        do: MapSet.put(change, :player_update),
        else: change

    {change, notifs ++ ps_notifs, state}
  end

  defp apply_penalties(state, _type, 0),
    do: state

  defp apply_penalties(state, :siege, coeff),
    do: apply_penalties(state, :under_siege_penalties, coeff, @limited_penalty_fields)

  defp apply_penalties(state, :workforce, coeff),
    do: apply_penalties(state, :workforce_penalties, coeff, @standard_penalty_fields)

  defp apply_penalties(state, :uprising, coeff),
    do: apply_penalties(state, :uprising_penalties, coeff, @standard_penalty_fields)

  defp apply_penalties(state, reason, coeff, fields) do
    fields
    |> Enum.map(fn key ->
      %{
        reason: {:misc, reason},
        bonus: %Core.Bonus{from: key, value: -coeff, type: :mul, to: key}
      }
    end)
    |> Enum.map(fn data -> expand_bonus(data, state) end)
    |> Enum.reduce(state, fn bonus_data, acc ->
      if bonus_data.to.to == :stellar_system and bonus_data.bonus.type == :mul,
        do: Core.Bonus.apply_bonus(bonus_data, stellar_system: acc, base_state: state),
        else: acc
    end)
  end

  # Helper state functions

  defp open_system(state) do
    c = Data.Querier.one(Data.Game.Constant, state.instance_id, :main)

    {body_uid, building_key} =
      if Enum.any?(state.bodies, fn body -> body.type == :habitable_planet end) do
        body =
          state.bodies
          |> Enum.filter(fn body -> body.type == :habitable_planet end)
          |> Enum.max_by(fn body -> length(body.tiles) end)

        {body.uid, :infra_open}
      else
        body =
          state.bodies
          |> Enum.filter(fn body -> body.type == :sterile_planet end)
          |> Enum.max_by(fn body -> length(body.tiles) end)

        {body.uid, :infra_dome}
      end

    %{
      state
      | bodies:
          update_tile(state.bodies, body_uid, 1, fn tile ->
            StellarSystem.Tile.force_building(tile, building_key, 1)
          end),
        population: Core.DynamicValue.new(c.system_starting_population),
        population_class: :minor
    }
  end

  # WARN:
  # this function doesn't compute local population for sub bodies (moons and asteroids)
  # this is for optimization purpose, no population point can be living on these bodies
  defp compute_local_population(state) do
    buildings_data = Data.Querier.all(Data.Game.Building, state.instance_id)

    bodies =
      Enum.map(state.bodies, fn body ->
        local_habitation =
          Enum.reduce(body.tiles, 0, fn tile, acc ->
            if tile.building_status == :empty do
              acc
            else
              building_data = Enum.find(buildings_data, fn b -> b.key == tile.building_key end)
              building_level_data = Enum.find(building_data.levels, fn l -> l.level == tile.building_level end)

              tile_habitations =
                Enum.reduce(building_level_data.bonus, 0, fn bonus, acc2 ->
                  out_data = Data.Querier.one(Data.Game.BonusPipelineOut, state.instance_id, bonus.to)

                  acc2 +
                    if out_data.to_key == :habitation,
                      do: bonus.value,
                      else: 0
                end)

              acc + tile_habitations
            end
          end)

        local_population =
          if state.habitation.value > 0,
            do: Kernel.trunc(state.workforce * local_habitation / state.habitation.value),
            else: 0

        %{body | population: local_population}
      end)

    %{state | bodies: bodies}
  end

  defp compute_used_workforce(state) do
    used_workforce =
      Enum.reduce(flatten_bodies(state.bodies), 0, fn body, acc1 ->
        acc1 +
          Enum.reduce(body.tiles, 0, fn tile, acc2 ->
            building = Data.Querier.one(Data.Game.Building, state.instance_id, tile.building_key)

            acc2 +
              if Enum.member?([:built, :damaged], tile.building_status),
                do: building.workforce,
                else: 0
          end)
      end)

    %{state | used_workforce: used_workforce}
  end

  defp update_population_class(state) do
    Data.Game.PopulationClass
    |> Data.Querier.all(state.instance_id)
    |> Enum.reduce_while(state, fn class, acc ->
      if state.population.value >= class.threshold,
        do: {:halt, %{acc | population_class: class.key}},
        else: {:cont, acc}
    end)
  end

  defp update_population_status(former_population_status, former_happiness, state)
       when former_happiness != state.happiness.value do
    pop_status =
      Data.Querier.all(Data.Game.PopulationStatus, state.instance_id)
      |> Enum.reduce(nil, fn pop_status, acc ->
        if state.happiness.value <= pop_status.threshold,
          do: pop_status,
          else: acc
      end)

    state = %{state | population_status: pop_status.key}

    notifs =
      if former_population_status == :normal and state.population_status != :normal do
        [Notification.Text.new(:start_uprising, state.id, %{system: state.name})]
      else
        []
      end

    {state, notifs, pop_status}
  end

  defp update_population_status(_former_population_status, _former_happiness, state) do
    pop_status = Data.Querier.one(Data.Game.PopulationStatus, state.instance_id, state.population_status)
    {state, [], pop_status}
  end

  defp reset_system_value_fields(state) do
    state =
      Enum.reduce(state, state, fn {key, value}, acc ->
        cond do
          Util.Type.advanced_value?(value) -> Map.replace!(acc, key, Core.Value.new())
          key == :remove_contact -> Map.replace!(acc, key, Core.DynamicValue.new(Map.get(acc, key).value))
          true -> acc
        end
      end)

    %{state | bodies: reset_bodies_value_fields(state.bodies)}
  end

  defp reset_bodies_value_fields(bodies) do
    Enum.map(bodies, fn body ->
      body =
        Enum.reduce(body, body, fn {key, value}, acc ->
          if Util.Type.advanced_value?(value),
            do: Map.replace!(acc, key, Core.Value.new()),
            else: acc
        end)

      %{body | bodies: reset_bodies_value_fields(body.bodies)}
    end)
  end

  # Helper functions

  defp flatten_bodies(bodies) do
    Enum.reduce(bodies, [], fn body, acc ->
      [body | acc] ++ flatten_bodies(body.bodies)
    end)
  end

  defp extract_buildings(bodies) do
    bodies
    |> flatten_bodies()
    |> Enum.map(fn body ->
      Enum.map(body.tiles, fn tile ->
        if tile.building_status === :built,
          do: [%{key: tile.building_key, level: tile.building_level, stellar_body: body}],
          else: []
      end)
    end)
    |> List.flatten()
  end

  defp extract_body(bodies, body_uid) do
    bodies
    |> flatten_bodies
    |> Enum.find(fn body -> body.uid == body_uid end)
  end

  defp extract_tile(bodies, body_uid, tile_id) do
    try do
      bodies
      |> flatten_bodies()
      |> Enum.each(fn body ->
        if body.uid == body_uid do
          tile = Enum.find(body.tiles, fn tile -> tile.id == tile_id end)
          if tile != nil, do: throw(tile)
        end
      end)

      nil
    catch
      tile -> tile
    end
  end

  defp update_tile(bodies, body_uid, tile_id, func) do
    Enum.map(bodies, fn body ->
      %{
        body
        | tiles:
            Enum.map(body.tiles, fn tile ->
              if body.uid == body_uid and tile.id == tile_id,
                do: func.(tile),
                else: tile
            end),
          bodies: update_tile(body.bodies, body_uid, tile_id, func)
      }
    end)
  end

  defp damage_tile(bodies, instance_id) do
    tile_choices =
      bodies
      |> flatten_bodies()
      |> Enum.map(fn body ->
        Enum.map(body.tiles, fn tile ->
          # remove infrastructure and currently constructed building
          # double defense building probablility
          if tile.construction_status == :none and tile.building_status == :built and tile.type != :infrastructure do
            building_data = Data.Querier.one(Data.Game.Building, instance_id, tile.building_key)
            i = if :defense in building_data.outputs, do: 2, else: 1
            List.duplicate({body.uid, tile.id}, i)
          else
            []
          end
        end)
      end)
      |> List.flatten()

    if Enum.empty?(tile_choices) do
      {:nothing_to_damage, bodies}
    else
      {body_uid, tile_id} = Game.call(instance_id, :rand, :master, {:random, tile_choices})
      bodies = update_tile(bodies, body_uid, tile_id, &StellarSystem.Tile.damage_building/1)
      {:damaged, bodies}
    end
  end

  defp expand_bonus(data, state, metadata \\ %{}) do
    %{
      metadata: metadata,
      reason: data.reason,
      bonus: data.bonus,
      from: Data.Querier.one(Data.Game.BonusPipelineIn, state.instance_id, data.bonus.from),
      to: Data.Querier.one(Data.Game.BonusPipelineOut, state.instance_id, data.bonus.to)
    }
  end

  defp transform_to_starter_system(state) do
    bodies =
      StellarSystem.StarterStellarSystemData.content()
      |> Enum.with_index()
      |> Enum.map(fn {body, i} ->
        StellarSystem.StellarBody.new_from_model(i + 1, body, state.name, :primary)
      end)

    %{state | bodies: bodies}
  end

  defp compute_value(state) do
    flatten_bodies(state.bodies)
    |> Enum.reduce(0, fn body, acc ->
      acc +
        Enum.reduce(body.tiles, 0, fn tile, acc2 ->
          if tile.building_status == :built,
            do: acc2 + 1,
            else: acc2
        end)
    end)
  end

  defp collect_initial_bonuses(state) do
    c = Data.Querier.one(Data.Game.Constant, state.instance_id, :main)

    base_production =
      if state.capital?,
        do: c.system_capital_base_production,
        else: c.system_base_production

    base_defense =
      if state.status == :inhabited_player,
        do: c.system_base_defense * state.workforce,
        else: 0

    base_population = c.system_population_negative_happiness_factor * state.workforce
    base_taxes = c.system_population_taxes_factor * state.workforce
    base_mobility = c.system_mobility_taxes_factor * state.workforce

    [
      %{
        reason: {:misc, :initial},
        bonus: %Core.Bonus{from: :direct, value: base_production, type: :add, to: :sys_production}
      },
      %{
        reason: {:misc, :initial},
        bonus: %Core.Bonus{from: :direct, value: c.system_base_happiness, type: :add, to: :sys_happiness}
      },
      %{
        reason: {:misc, :initial},
        bonus: %Core.Bonus{from: :direct, value: base_defense, type: :add, to: :sys_defense}
      },
      %{
        reason: {:misc, :population},
        bonus: %Core.Bonus{from: :direct, value: base_population, type: :add, to: :sys_happiness}
      },
      %{
        reason: {:misc, :population_taxes},
        bonus: %Core.Bonus{from: :direct, value: base_taxes, type: :add, to: :sys_credit}
      },
      %{
        reason: {:misc, :population_mobility},
        bonus: %Core.Bonus{from: :sys_mobility, value: base_mobility, type: :mul, to: :sys_credit}
      },
      %{
        reason: {:misc, :initial},
        bonus: %Core.Bonus{from: :direct, value: @base_radar, type: :add, to: :sys_radar}
      }
    ]
  end

  defp collect_happiness_penalties(state) do
    Enum.map(state.happiness_penalties, fn %{reason: reason, value: value} ->
      %{
        reason: {:happiness_penalties, reason},
        bonus: %Core.Bonus{from: :direct, value: -value, type: :add, to: :sys_happiness}
      }
    end)
  end
end
