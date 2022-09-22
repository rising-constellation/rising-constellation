defmodule Fight.Ship do
  use TypedStruct

  @damages_to_xp_factor 0.01
  @morale_loss_by_unit_lost 0.3
  @morale_loss_by_ship_lost 2.5
  @handling_against_energy 0.75
  @handling_against_explosive 1

  typedstruct enforce: true do
    field(:key, atom())
    field(:ref, tuple())
    field(:data, %{})
    field(:name, nil | String.t())
    field(:level, integer())
    field(:gained_xp, float())
    field(:morale, integer())
    field(:units, [%Fight.ShipUnit{}])
    field(:target, nil | tuple())
    field(:status, :alive | :escaping | :destroyed)
  end

  def convert(ship, character_id, character_level, tile_id, constant, ships_data) do
    ship_data = Enum.find(ships_data, fn ship_data -> ship_data.key == ship.key end)

    # +0.5% per level of base energy_strikes and explosive strikes
    energy_strikes = Enum.map(ship_data.unit_energy_strikes, fn s -> s * (1 + 0.01 * ship.level) end)
    explosive_strikes = Enum.map(ship_data.unit_explosive_strikes, fn s -> s * (1 + 0.01 * ship.level) end)

    # +0.1 pts per level, capped at 95
    handling = Enum.min([ship_data.unit_handling + 0.5 * ship.level, 95])

    # +0.1 pts per level if interception is not 0, capped at 95
    interception =
      if ship_data.unit_interception > 0,
        do: Enum.min([ship_data.unit_interception + 0.5 * ship.level, 95]),
        else: ship_data.unit_interception

    # +0.1 pts per level if shield is not 0, capped at 95
    shield =
      if ship_data.unit_shield > 0,
        do: Enum.min([ship_data.unit_shield + 0.5 * ship.level, 95]),
        else: ship_data.unit_shield

    ship_data = %{
      ship_data
      | unit_energy_strikes: energy_strikes,
        unit_explosive_strikes: explosive_strikes,
        unit_handling: handling,
        unit_interception: interception,
        unit_shield: shield
    }

    # create units in ship
    units = Enum.map(ship.units, fn unit -> Fight.ShipUnit.convert(unit) end)

    # update moral value
    morale =
      constant.army_unit_base_morale + ship.level * constant.army_unit_morale_per_level +
        character_level * constant.army_unit_morale_per_level

    %Fight.Ship{
      key: ship.key,
      ref: {character_id, tile_id},
      data: ship_data,
      name: ship.name,
      level: ship.level,
      gained_xp: 0.0,
      morale: morale,
      units: units,
      target: nil,
      status: :alive
    }
    |> update_status()
  end

  def compute_life(state) do
    {Enum.reduce(state.units, 0, fn unit, acc -> acc + unit.hull end), state.data.unit_count * state.data.unit_hull}
  end

  def ref(state) do
    {character_id, tile_id} = state.ref
    %{character: character_id, tile: tile_id}
  end

  def update_status(state) do
    status =
      cond do
        alive_units_count(state) == 0 -> :destroyed
        state.status == :escaping -> :escaping
        true -> :alive
      end

    %{state | status: status}
  end

  def set_escaping(state) when state.morale <= 0, do: %{state | status: :escaping}
  def set_escaping(state), do: state

  def alive_units_count(state) do
    Enum.count(state.units, fn u -> u.status == :alive end)
  end

  def has_target?(state), do: state.target != nil
  def set_target(state, ref), do: %{state | target: ref}
  def unset_target(state), do: %{state | target: nil}

  def choose_unit(instance_id, state) do
    available_units = Enum.filter(state.units, fn unit -> unit.status == :alive end)

    if not Enum.empty?(available_units) do
      Game.call(instance_id, :rand, :master, {:random, available_units})
    else
      :no_unit_available
    end
  end

  def update_unit(state, unit) do
    %{state | units: Enum.map(state.units, fn u -> if u.id == unit.id, do: unit, else: u end)}
  end

  def add_gained_xp(state, damages) do
    %{state | gained_xp: state.gained_xp + damages * @damages_to_xp_factor}
  end

  def loose_morale(state, morale_loss) do
    %{state | morale: Enum.max([state.morale - morale_loss, 0])}
  end

  def loose_morale_by_damages(state, damages) do
    {_current, total} = compute_life(state)
    damages_ratio = damages / total

    morale_loss =
      cond do
        damages_ratio < 0.05 -> 0
        damages_ratio < 0.1 -> 1
        damages_ratio < 0.2 -> 2
        damages_ratio < 0.3 -> 6
        damages_ratio < 0.4 -> 10
        true -> 15
      end

    %{state | morale: Enum.max([state.morale - morale_loss, 0])}
  end

  def engage(instance_id, state, target) do
    Enum.reduce(state.units, {0, [], state, target}, fn unit, {global_morale_loss, log, s_acc, t_acc} ->
      if has_target?(s_acc) and unit.status == :alive do
        previous_alive_units = alive_units_count(t_acc)

        # 1. state strike target
        {strikes, s_acc, t_acc} = Fight.Ship.do_strikes(instance_id, {s_acc, t_acc})

        # 2. state gain xp and target loose morale
        damages = Enum.reduce(strikes, 0, fn s, damages -> damages + s.damages end)
        s_acc = add_gained_xp(s_acc, damages)
        t_acc = loose_morale_by_damages(t_acc, damages)

        # 3. if target.ship_unit loose a ship_unit increase global_morale_loss
        # if target is completely destroyed, increase global_morale_loss
        alive_units = alive_units_count(t_acc)
        lost_units = previous_alive_units - alive_units

        global_morale_loss =
          if previous_alive_units == alive_units do
            global_morale_loss
          else
            global_morale_loss = global_morale_loss + lost_units * @morale_loss_by_unit_lost

            if alive_units == 0,
              do: global_morale_loss + @morale_loss_by_ship_lost,
              else: global_morale_loss
          end

        # 4. log actions
        log = log ++ [%{source: unit.id, strikes: strikes}]

        {global_morale_loss, log, s_acc, t_acc}
      else
        {global_morale_loss, log, s_acc, t_acc}
      end
    end)
  end

  def do_strikes(instance_id, {state, target}) do
    strikes =
      Enum.map(state.data.unit_energy_strikes, fn s -> {:energy, s} end) ++
        Enum.map(state.data.unit_explosive_strikes, fn s -> {:explosive, s} end)

    Enum.reduce(strikes, {[], state, target}, fn {strike_type, damage}, {log, s_acc, t_acc} ->
      case Fight.Ship.choose_unit(instance_id, t_acc) do
        :no_unit_available ->
          {log ++ [%{target: nil, action: :waiting, damages: 0}], s_acc, t_acc}

        unit_target ->
          case apply_damages_and_defenses(t_acc, instance_id, unit_target, strike_type, damage) do
            {:hit, {unit_target, action, damages}} ->
              t_acc =
                t_acc
                |> Fight.Ship.update_unit(unit_target)
                |> Fight.Ship.update_status()

              {log ++ [%{target: unit_target.id, action: action, damages: damages}], s_acc, t_acc}

            {:avoided, _unit_target} ->
              {log ++ [%{target: unit_target.id, action: :missed, damages: 0}], s_acc, t_acc}
          end
      end
    end)
  end

  defp apply_damages_and_defenses(state, instance_id, unit, strike_type, damage) do
    # take the unit_handling [0-100] and transform to [0-1]
    # if strike_type is energy, we decrease it by 25% (handling is less efficient)
    # against energy weapon
    handling =
      case strike_type do
        :energy -> state.data.unit_handling / 100 * @handling_against_energy
        :explosive -> state.data.unit_handling / 100 * @handling_against_explosive
      end

    if Game.call(instance_id, :rand, :master, {:uniform}) < handling do
      {:avoided, unit}
    else
      damage =
        case strike_type do
          :energy ->
            shield = state.data.unit_shield / 100
            damage - damage * shield

          :explosive ->
            interception = state.data.unit_interception / 100

            if Game.call(instance_id, :rand, :master, {:uniform}) < interception,
              do: 0,
              else: damage
        end

      if damage <= 0,
        do: {:avoided, unit},
        else: {:hit, Fight.ShipUnit.apply_damages(unit, damage)}
    end
  end
end
