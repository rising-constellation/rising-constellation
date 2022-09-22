defmodule Instance.Character.Character do
  use TypedStruct
  use Util.MakeEnumerable

  alias Instance.Character
  alias Instance.Character.Action
  alias Instance.Character.ActionQueue
  alias Instance.Character.ActionImpl
  alias Spatial
  alias Spatial.Position

  @max_level 12

  def jason(), do: [except: [:instance_id, :second_specialization, :bonuses]]

  typedstruct enforce: true do
    field(:id, integer())
    field(:status, :for_hire | :in_deck | :governor | :on_board | :dead)
    field(:type, :admiral | :spy | :speaker)
    field(:specialization, atom())
    field(:second_specialization, atom())
    field(:skills, [integer()])

    field(:age, integer())
    field(:culture, atom())
    field(:name, String.t())
    field(:gender, atom())
    field(:illustration, String.t())

    field(:level, integer())
    field(:experience, %Core.DynamicValue{})
    field(:protection, integer())
    field(:determination, integer())

    field(:credit_cost, integer())
    field(:technology_cost, integer())
    field(:ideology_cost, integer())

    # hired character
    field(:owner, %Character.Player{} | nil)
    field(:on_sold, boolean())

    # activated character
    field(:system, integer() | nil)
    field(:position, %Position{} | nil)

    # on_board character
    field(:actions, %ActionQueue{} | nil)
    field(:action_status, :idle | :moving | :docking | atom() | nil)
    field(:on_strike, boolean())
    field(:army, %Character.Army{} | nil)
    field(:spy, %Character.Spy{} | nil)
    field(:speaker, %Character.Speaker{} | nil)

    field(:bonuses, %{}, default: %{})
    field(:instance_id, integer())
  end

  defp random(arg, instance_id) do
    Game.call(instance_id, :rand, :master, {:random, arg})
  end

  def new(id, type, rank, nth, instance_id, initial_data \\ nil) do
    type_data = Data.Querier.one(Data.Game.Character, instance_id, type)
    rank_data = Data.Querier.one(Data.Game.CharacterRank, instance_id, rank)

    {specialization, second_specialization, initial_skill_points, skills} =
      if initial_data do
        {initial_data.spec1, initial_data.spec2, 0, initial_data.skills}
      else
        skills = [0, 0, 0, 0, 0, 0]
        initial_skill_points = random(rank_data.initial_skill_points_range, instance_id)
        specialization = random(type_data.specializations, instance_id).key

        second_specialization =
          (Enum.filter(type_data.specializations, fn s -> s.key != specialization end)
           |> random(instance_id)).key

        {specialization, second_specialization, initial_skill_points, skills}
      end

    specs =
      Data.Querier.all(Data.Game.CharacterIllustration, instance_id)
      |> Enum.filter(fn i -> i.type == type and i.rank == rank and specialization not in i.forb_specializations end)
      |> random(instance_id)

    # TODO: use correct culture with initial data when there is enough characters illustrations
    culture_data = Data.Querier.one(Data.Game.Culture, instance_id, specs.culture)
    firstname = Data.Picker.random(Map.get(culture_data.firstname_repo, specs.gender), instance_id)
    lastname = Data.Picker.random(culture_data.lastname_repo, instance_id)

    initial_experience = random(rank_data.initial_experience_range, instance_id)
    initial_protection = random(rank_data.initial_protection_range, instance_id)
    initial_determination = random(rank_data.initial_determination_range, instance_id)

    nth_factor = 1 + nth * rank_data.nth_factor

    credit = random(type_data.credit_cost_range, instance_id) * rank_data.cost_factor * nth_factor
    technology = random(type_data.technology_cost_range, instance_id) * rank_data.cost_factor * nth_factor
    ideology = random(type_data.ideology_cost_range, instance_id) * rank_data.cost_factor * nth_factor

    state =
      %Character.Character{
        id: id,
        status: :for_hire,
        type: type,
        specialization: specialization,
        second_specialization: second_specialization,
        skills: skills,
        age: random(specs.age, instance_id),
        culture: specs.culture,
        name: "#{firstname} #{lastname}",
        gender: specs.gender,
        illustration: specs.filename,
        level: 0,
        experience: Core.DynamicValue.new(0.0),
        protection: type_data.initial_protection + initial_protection,
        determination: type_data.initial_determination + initial_determination,
        credit_cost: Kernel.trunc(credit),
        technology_cost: Kernel.trunc(technology),
        ideology_cost: Kernel.trunc(ideology),
        owner: nil,
        on_sold: false,
        system: nil,
        position: nil,
        actions: nil,
        action_status: nil,
        on_strike: false,
        army: nil,
        spy: nil,
        speaker: nil,
        instance_id: instance_id
      }
      |> add_skill_point(initial_skill_points)

    {_, _, state} = gain_experience({MapSet.new(), [], state}, initial_experience)
    compute_bonus(state)
  end

  def new_initial(id, faction_key, instance_id) do
    faction_data = Data.Querier.one(Data.Game.Faction, instance_id, faction_key)

    initial_data = %{
      culture: faction_data.culture,
      spec1: faction_data.initial_character_spec1,
      spec2: faction_data.initial_character_spec2,
      skills: faction_data.initial_character_skills
    }

    new(id, faction_data.initial_character_type, :common, 1, instance_id, initial_data)
  end

  def convert_from_battle(%Character.Character{} = pre_fight_character, %Fight.Army{} = post_fight_army) do
    %{pre_fight_character | army: Character.Army.convert_from_battle(pre_fight_character.army, post_fight_army)}
    |> compute_bonus()
  end

  def compute_next_tick_interval(%Character.Character{status: :governor} = state) do
    get_next_level_remaining_time(state)
  end

  def compute_next_tick_interval(%Character.Character{} = state) do
    # TODO: calculate when the cover will change
    spy = if state.type == :spy and state.spy.cover.value < 100, do: 2, else: :never
    strike = if state.on_strike, do: 2, else: :never

    speaker =
      if state.type == :speaker,
        do: Core.CooldownValue.next_tick_interval(state.speaker.cooldown),
        else: :never

    action =
      if not ActionQueue.empty?(state.actions),
        do: ActionQueue.get_next_action_remaining_time(state.actions),
        else: :never

    Enum.min([spy, strike, speaker, action])
  end

  # Generic action handling

  def hire(%Character.Character{} = state, player),
    do: %{state | owner: Character.Player.convert(player), status: :in_deck}

  def convert(%Character.Character{} = state, new_id, player),
    do: %{state | owner: Character.Player.convert(player), id: new_id}

  def set_on_sold(%Character.Character{} = state),
    do: %{state | on_sold: true}

  def unset_on_sold(%Character.Character{} = state),
    do: %{state | on_sold: false}

  def update_owner(%Character.Character{} = state, new_player),
    do: %{state | owner: Character.Player.convert(new_player)}

  def activate(%Character.Character{} = state, :governor, system_id) do
    {:ok, position} = Game.call(state.instance_id, :stellar_system, system_id, :get_position)
    state = %{state | status: :governor, system: system_id, position: position}
    Spatial.delete(state)
    state
  end

  def activate(%Character.Character{} = state, :on_board, system_id) do
    {:ok, position} = Game.call(state.instance_id, :stellar_system, system_id, :get_position)

    army =
      if state.type == :admiral,
        do: Character.Army.new(state.instance_id),
        else: nil

    spy =
      if state.type == :spy,
        do: Character.Spy.new(),
        else: nil

    speaker =
      if state.type == :speaker,
        do: Character.Speaker.new(),
        else: nil

    actions =
      ActionQueue.new()
      |> ActionQueue.set_virtual_position(system_id)

    state =
      %{
        state
        | status: :on_board,
          system: system_id,
          position: position,
          actions: actions,
          action_status: :idle,
          army: army,
          spy: spy,
          speaker: speaker
      }
      |> compute_bonus()

    Spatial.delete(state)
    state
  end

  def deactivate(%Character.Character{} = state) do
    state = %{
      state
      | status: :in_deck,
        system: nil,
        position: nil,
        actions: nil,
        action_status: nil,
        army: nil,
        spy: nil,
        speaker: nil
    }

    Spatial.delete(state)
    state
  end

  def add_actions(%Character.Character{} = state, actions, pre_validate_action) do
    Enum.reduce(actions, state, fn action, state ->
      %{state | actions: pre_validate_action.(state, action)}
    end)
  end

  def set_virtual_position(%Character.Character{} = state, virtual_position),
    do: %{state | actions: ActionQueue.set_virtual_position(state.actions, virtual_position)}

  def set_virtual_position_and_clear(%Character.Character{} = state),
    do: %{state | actions: ActionQueue.set_virtual_position_and_clear(state.actions)}

  @doc "empties the queue, sets virtual_position to `nil`"
  def clear_actions(%Character.Character{} = state),
    do: %{state | actions: ActionQueue.new()}

  def clear_actions_after(%Character.Character{} = state, index),
    do: %{state | actions: ActionQueue.clear_after(state.actions, index)}

  @doc "aborts the current action removes it from queue, next action will start soon after"
  def abort_action(%Character.Character{} = state),
    do: %{state | actions: ActionQueue.abort_action(state.actions)}

  def leave_system(%Character.Character{} = state),
    do: %{state | system: nil, action_status: :moving}

  def enter_system(%Character.Character{} = state, system_id, %Position{} = system_position) do
    character = %{state | system: system_id, position: system_position, action_status: :idle}
    Spatial.delete(character)
    character
  end

  def start_action(%Character.Character{} = state, type),
    do: %{state | action_status: type}

  def finish_action(%Character.Character{} = state),
    do: %{state | action_status: :idle}

  def idle(%Character.Character{} = state),
    do: %{state | action_status: :idle}

  def update_strike(%Character.Character{} = state, player_is_bankrupt) do
    on_strike = player_is_bankrupt

    state =
      if on_strike and not is_nil(state.army),
        do: update_reaction(state, :flee),
        else: state

    %{state | on_strike: on_strike}
  end

  def add_experience(%Character.Character{} = state, amount) do
    {MapSet.new(), [], state}
    |> gain_experience(amount)
  end

  def update_bonuses(%Character.Character{} = state, from, bonuses) do
    %{state | bonuses: Map.put(state.bonuses, from, bonuses)}
    |> compute_bonus()
  end

  def fix(%Character.Character{} = state, systems) do
    if state.action_status != :idle and not is_nil(state.actions) and is_nil(state.actions.virtual_position) do
      system_id = Instance.Galaxy.Galaxy.get_system_id_with_position(systems, state.position)
      actions = ActionQueue.set_virtual_position(ActionQueue.new(), system_id)
      {:fixed, %{state | action_status: :idle, actions: actions}}
    else
      {:no_fix_needed, state}
    end
  end

  # Admiral action handling

  def dock(%Character.Character{type: :admiral} = state),
    do: %{state | action_status: :docking}

  def flee(%Character.Character{type: :admiral} = state, target_id) do
    actions = [%{"type" => "jump", "data" => %{"source" => state.system, "target" => target_id}}]

    state
    |> set_virtual_position_and_clear()
    |> add_actions(actions, &ActionImpl.pre_validate_action/2)
  end

  def has_planned_ship?(%Character.Character{type: :admiral} = state),
    do: Character.Army.has_planned_ship?(state.army)

  def has_ship?(%Character.Character{type: :admiral} = state),
    do: Character.Army.has_ship?(state.army)

  def has_colonization_ship?(%Character.Character{type: :admiral} = state),
    do: Character.Army.has_colonization_ship?(state.army)

  def update_reaction(%Character.Character{type: :admiral} = state, reaction),
    do: %{state | army: Character.Army.update_reaction(state.army, reaction)}

  def consume_colonization_ship(%Character.Character{type: :admiral} = state) do
    %{state | army: Character.Army.consume_colonization_ship(state.army)}
    |> compute_bonus()
  end

  def order_ship(%Character.Character{type: :admiral} = state, production_data) do
    {_, tile_id, prod_key, _} = production_data

    try do
      if state.type != :admiral, do: throw(:wrong_character_type)
      unless Enum.member?([:idle, :docking], state.action_status), do: throw(:character_not_idle_or_docking)
      unless Character.Army.tile_empty?(state.army, tile_id), do: throw(:tile_not_empty)

      ship_data = Data.Querier.one(Data.Game.Ship, state.instance_id, prod_key)

      name =
        if ship_data.class == :capital,
          do: Data.Picker.random("ship", state.instance_id),
          else: nil

      state = dock(state)
      state = %{state | army: Character.Army.plan_ship(state.army, tile_id, ship_data, name)}

      {:ok, state}
    catch
      error -> {:error, error}
    end
  end

  def cancel_ship(%Character.Character{type: :admiral} = state, tile_id) do
    try do
      unless Character.Army.tile_planned?(state.army, tile_id), do: throw(:tile_not_planned)

      state = %{state | army: Character.Army.unplan_ship(state.army, tile_id)}

      state =
        if Character.Army.has_planned_ship?(state.army),
          do: state,
          else: idle(state)

      {:ok, state}
    catch
      error -> {:error, error}
    end
  end

  def cancel_all_ships(%Character.Character{type: :admiral} = state) do
    %{state | army: Character.Army.unplan_all_ships(state.army)}
    |> idle()
  end

  def put_ship(%Character.Character{type: :admiral} = state, tile_id, initial_xp) do
    constant = Data.Querier.one(Data.Game.Constant, state.instance_id, :main)

    army =
      state.army
      |> Character.Army.put_ship(tile_id, initial_xp, constant)

    state =
      %{state | army: army}
      |> compute_bonus()

    if Character.Army.has_planned_ship?(state.army),
      do: state,
      else: idle(state)
  end

  def remove_ship(%Character.Character{type: :admiral} = state, tile_id) do
    army = Character.Army.remove_ship(state.army, tile_id)

    %{state | army: army}
    |> compute_bonus()
  end

  def damage_army(%Character.Character{type: :admiral} = state, pv_to_remove) do
    {army, logs} = Character.Army.damage(state.army, state.instance_id, pv_to_remove)

    state =
      %{state | army: army}
      |> compute_bonus()

    {state, logs}
  end

  def sabotage_army(%Character.Character{type: :admiral} = state, target_pv) do
    {army, _logs} = Character.Army.sabotage(state.army, state.instance_id, target_pv)

    %{state | army: army}
    |> compute_bonus()
  end

  def compute_total_army_pv(%Character.Character{type: :admiral} = state) do
    Character.Army.compute_total_pv(state.army)
  end

  # basic officer
  def replace_agent_with_default(%Character.Character{type: :admiral} = state, instance_id) do
    name_first_part =
      Game.call(instance_id, :rand, :master, {:uniform, 9999})
      |> Integer.to_string()
      |> String.pad_leading(4, "0")

    name_second_part =
      Game.call(instance_id, :rand, :master, {:uniform, 9999})
      |> Integer.to_string()
      |> String.pad_leading(4, "0")

    %{
      state
      | skills: [0, 0, 0, 0, 0, 0],
        age: 21,
        name: "CMO ##{name_first_part}-#{name_second_part}",
        level: 1,
        experience: Core.DynamicValue.new(0),
        protection: 30,
        determination: 30
    }
    |> compute_bonus()
  end

  def get_position(%Character.Character{action_status: :moving} = state, instance_id) do
    # get position and angle/orientation indicating the direction of travel if moving
    action = state.actions.queue |> Queue.to_list() |> Enum.at(0)

    if is_nil(action) or is_nil(action.started_at) do
      {state.position, 0}
    else
      metadata = Data.Querier.get_metadata(instance_id)
      speed = Data.Querier.one(Data.Game.Speed, instance_id, metadata[:speed])

      percent = Action.compute_progress(action, speed.factor)

      pos1 = action.data["source_position"]
      pos2 = action.data["target_position"]

      p_x = Float.round(pos1.x + percent * (pos2.x - pos1.x), 2)
      p_y = Float.round(pos1.y + percent * (pos2.y - pos1.y), 2)

      angle = :math.atan2(pos2.y - pos1.y, pos2.x - pos1.x)
      {%Position{x: p_x, y: p_y}, angle}
    end
  end

  def get_position(%Character.Character{} = state, _instance_id) do
    {state.position, 0}
  end

  # Spy action handling

  def lose_cover(%Character.Character{type: :spy} = state, amount) do
    {spy, became_discovered?} = Character.Spy.lose_cover(state.spy, state.instance_id, amount)
    state = %{state | spy: spy}

    state =
      if became_discovered? do
        state
        |> compute_bonus()
        |> set_virtual_position_and_clear()
      else
        state
      end

    {state, became_discovered?}
  end

  # Speaker action handling

  def set_cooldown(%Character.Character{type: :speaker} = state, duration) do
    %{state | speaker: Character.Speaker.set_cooldown(state.speaker, duration)}
  end

  # Tick handling

  def next_tick(%Character.Character{} = state, elapsed_time, cumulated_pauses) do
    {MapSet.new(), [], state}
    |> update(elapsed_time, cumulated_pauses)
  end

  # Core functions

  defp update({change, notifs, %Character.Character{status: :governor} = state}, elapsed_time, _cumulated_pauses) do
    next_tick_experience = Core.DynamicValue.next_tick(state.experience, elapsed_time).value - state.experience.value
    gain_experience({change, notifs, state}, next_tick_experience)
  end

  defp update({change, notifs, %Character.Character{status: :on_board} = state}, elapsed_time, cumulated_pauses) do
    {change, notifs, state} =
      if state.type == :speaker do
        {speaker, has_changed} = Character.Speaker.update_cooldown(state.speaker, elapsed_time)

        change =
          if has_changed,
            do: MapSet.put(change, :player_update),
            else: change

        {change, notifs, %{state | speaker: speaker}}
      else
        {change, notifs, state}
      end

    if ActionQueue.empty?(state.actions) do
      case state.type do
        :admiral ->
          army = Character.Army.repair(state.army, state.instance_id, elapsed_time)
          {change, notifs, compute_bonus(%{state | army: army})}

        :spy ->
          {spy, has_changed} = Character.Spy.increase_cover(state.spy, state.instance_id, elapsed_time)

          change =
            if has_changed do
              change
              |> MapSet.put(:player_update)
              |> MapSet.put(:system_update)
            else
              change
            end

          {change, notifs, compute_bonus(%{state | spy: spy})}

        _ ->
          {change, notifs, state}
      end
    else
      process_action_queue({change, notifs, state}, elapsed_time, cumulated_pauses)
    end
  end

  defp process_action_queue({change, notifs, %Character.Character{} = state}, time_since_last_tick, cumulated_pauses) do
    case ActionQueue.process_next_action(state.actions, time_since_last_tick, cumulated_pauses) do
      :error ->
        {change, notifs, state}

      :empty ->
        {change, notifs, state}

      :queue_locked ->
        {change, notifs, state}

      {:to_start, action, actions} ->
        if state.on_strike do
          {change, notifs, state}
        else
          state = %{state | actions: actions}
          state = orchestrate(:start, state, action)
          {MapSet.put(change, :player_update), notifs, state}
        end

      {:ongoing, _action, actions} ->
        state = %{state | actions: actions}
        {change, notifs, state}

      {:to_finish, action, actions} ->
        state = %{state | actions: actions}
        state = orchestrate(:finish, state, action)
        {MapSet.put(change, :player_update), notifs, state}
    end
  end

  defp orchestrate(hook_type, %Character.Character{} = character, action) do
    character = lock_queue(character)
    Game.cast(character.instance_id, :action_orchestrator, :master, {hook_type, character, action})

    character
  end

  defp gain_experience({change, notifs, %Character.Character{} = state}, amount) do
    next_level_experience = get_next_level_experience(state)

    if amount > next_level_experience do
      change =
        change
        |> MapSet.put(:player_update)
        |> MapSet.put(:system_update)

      state =
        %{state | experience: Core.DynamicValue.add_value(state.experience, next_level_experience)}
        |> level_up()

      notifs =
        if state.system,
          do: [
            Notification.Text.new(:character_lvlup, state.system, %{character: state.name, level: state.level}) | notifs
          ],
          else: notifs

      gain_experience({change, notifs, state}, amount - next_level_experience)
    else
      {change, notifs, %{state | experience: Core.DynamicValue.add_value(state.experience, amount)}}
    end
  end

  # Helper functions

  defp lock_queue(%Character.Character{} = state) do
    actions = ActionQueue.lock(state.actions)
    %{state | actions: actions}
  end

  defp get_next_level_remaining_time(%Character.Character{} = state) do
    get_next_level_experience(state) / state.experience.change
  end

  defp get_next_level_experience(%Character.Character{} = state) do
    Float.round(10 * (state.level + 1) + :math.pow((state.level + 1) / 2, 2.5)) - state.experience.value
  end

  defp level_up(%Character.Character{} = state) do
    type_data = Data.Querier.one(Data.Game.Character, state.instance_id, state.type)

    protection = state.protection + type_data.gain_protection

    protection =
      if protection >= type_data.max_protection,
        do: type_data.max_protection,
        else: protection

    determination = state.determination + type_data.gain_determination

    determination =
      if determination >= type_data.max_determination,
        do: type_data.max_determination,
        else: determination

    %{state | level: state.level + 1, protection: protection, determination: determination}
    |> add_skill_point(1)
    |> compute_bonus()
  end

  defp add_skill_point(%Character.Character{} = state, 0),
    do: state

  defp add_skill_point(%Character.Character{} = state, amount) do
    type_data = Data.Querier.one(Data.Game.Character, state.instance_id, state.type)

    {_, main_skill_index} =
      type_data.specializations
      |> Enum.with_index()
      |> Enum.find(fn {e, _} -> e.key == state.specialization end)

    {_, second_skill_index} =
      type_data.specializations
      |> Enum.with_index()
      |> Enum.find(fn {e, _} -> e.key == state.second_specialization end)

    main_skill_value = Enum.at(state.skills, main_skill_index)

    probability_list =
      state
      |> get_possible_skills(main_skill_index, main_skill_value)
      |> compute_skills_probabilities(main_skill_index, second_skill_index)

    if Enum.empty?(probability_list) do
      state
    else
      probability_sum =
        probability_list
        |> Enum.reduce(0, fn el, acc -> acc + el.probability end)

      seed = Game.call(state.instance_id, :rand, :master, {:uniform}) * probability_sum

      chosen_index =
        Enum.reduce_while(probability_list, 0, fn el, acc ->
          threshold = acc + el.probability

          if seed <= threshold,
            do: {:halt, el.index},
            else: {:cont, threshold}
        end)

      skills =
        state.skills
        |> Enum.with_index()
        |> Enum.map(fn {x, i} -> if i == chosen_index, do: x + 1, else: x end)

      state = %{state | skills: skills}

      add_skill_point(state, amount - 1)
    end
  end

  # Helper functions

  defp compute_bonus(%Character.Character{} = state) do
    # reset
    state =
      Enum.reduce(state, state, fn {key, value}, acc ->
        cond do
          Util.Type.advanced_value?(value) -> Map.replace!(acc, key, Core.Value.new())
          Util.Type.advanced_dynamic_value?(value) -> Map.replace!(acc, key, Core.DynamicValue.new(value.value))
          true -> acc
        end
      end)

    # update
    state =
      if state.status == :on_board do
        case state.type do
          :admiral ->
            army = Character.Army.compute_bonus(state.army, state.instance_id, extract_bonus(state, [:army]))
            %{state | army: army}

          :spy ->
            spy = Character.Spy.compute_bonus(state.spy, state.instance_id, extract_bonus(state, [:spy]))
            %{state | spy: spy}

          :speaker ->
            speaker =
              Character.Speaker.compute_bonus(state.speaker, state.instance_id, extract_bonus(state, [:speaker]))

            %{state | speaker: speaker}
        end
      else
        state
      end

    bonuses =
      Enum.map(extract_bonus(state, [:character]), fn data ->
        %{
          reason: data.reason,
          bonus: data.bonus,
          from: Data.Querier.one(Data.Game.BonusPipelineIn, state.instance_id, data.bonus.from),
          to: Data.Querier.one(Data.Game.BonusPipelineOut, state.instance_id, data.bonus.to)
        }
      end)
      |> Enum.filter(fn bonus_data -> bonus_data.to.to == :character end)

    Core.Bonus.apply_bonuses(state, :character, bonuses)
  end

  def extract_bonus(%Character.Character{} = state, target) do
    constant = Data.Querier.one(Data.Game.Constant, state.instance_id, :main)

    # extract initial bonus
    initial_xp = constant.character_passive_xp_gain

    initial_bonuses =
      if Enum.member?(target, :character) do
        [
          %{
            reason: {:misc, :initial_experience},
            bonus: %Core.Bonus{from: :direct, value: initial_xp, type: :add, to: :character_experience}
          }
        ]
      else
        []
      end

    # extract bonus from skills
    character_data = Data.Querier.one(Data.Game.Character, state.instance_id, state.type)

    skills_bonus =
      Enum.flat_map(Enum.with_index(state.skills), fn {skill, i} ->
        skill_data = Enum.find(character_data.specializations, fn s -> s.index == i end)

        Enum.flat_map(skill_data.bonus, fn bonus ->
          bonus = %{bonus | value: bonus.value * skill}
          to = Data.Querier.one(Data.Game.BonusPipelineOut, state.instance_id, bonus.to)

          if Enum.member?(target, to.to),
            do: [%{reason: {:agent, state.name}, bonus: bonus}],
            else: []
        end)
      end)

    # extract bonus from outside
    outside_bonuses =
      state.bonuses
      |> Enum.map(fn {_, bonuses} -> bonuses end)
      |> List.flatten()
      |> Enum.filter(fn %{bonus: bonus} ->
        to = Data.Querier.one(Data.Game.BonusPipelineOut, state.instance_id, bonus.to)
        Enum.member?(target, to.to)
      end)

    List.flatten([initial_bonuses, skills_bonus, outside_bonuses])
  end

  defp get_possible_skills(%Character.Character{skills: skills}, main_skill_index, main_skill_value) do
    skills
    |> Enum.with_index()
    |> Enum.reduce([], fn {value, i}, acc ->
      if value < @max_level and (i == main_skill_index or value < main_skill_value),
        do: acc ++ [%{index: i, value: value, probability: 0}],
        else: acc
    end)
  end

  defp compute_skills_probabilities(possible_skills, main_skill_index, second_skill_index) do
    possible_skills
    |> Enum.map(fn el ->
      probability =
        cond do
          el.index == main_skill_index -> 8
          el.index == second_skill_index -> 5
          true -> 1
        end

      %{el | probability: probability}
    end)
  end
end
