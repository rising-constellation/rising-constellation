defmodule Instance.StellarSystem.Tile do
  require Logger

  use TypedStruct
  use Util.MakeEnumerable

  alias Instance.StellarSystem.Tile

  def jason(), do: []

  typedstruct enforce: true do
    field(:id, integer())
    field(:type, atom())
    field(:construction_status, :none | :new | :upgrade | :repair | :hidden)
    field(:building_status, :empty | :built | :damaged | :hidden)
    field(:building_key, atom() | nil)
    field(:building_level, integer() | nil | :hidden)
  end

  def new(id, body_type) do
    type =
      if body_type == :primary and id == 1,
        do: :infrastructure,
        else: :normal

    %Tile{
      id: id,
      type: type,
      construction_status: :none,
      building_status: :empty,
      building_key: nil,
      building_level: nil
    }
  end

  # arbitrary "force-put" building without production planned
  def force_building(%Tile{} = state, building_key, building_level),
    do: %{state | building_status: :built, building_key: building_key, building_level: building_level}

  # plan building on empty tile
  def plan_building(%Tile{building_status: :empty, construction_status: :none} = state, building_key),
    do: %{state | construction_status: :new, building_key: building_key}

  # plan building upgrade
  def plan_building(%Tile{building_status: :built, construction_status: :none} = state, _building_key),
    do: %{state | construction_status: :upgrade}

  # plan building default
  def plan_building(%Tile{} = state, _building_key) do
    Logger.warn("Tile.plan_building/2 missing clause, state: #{inspect(state)}")
    state
  end

  # unplan new building
  def unplan_building(%Tile{construction_status: :new} = state),
    do: %{state | construction_status: :none, building_key: nil}

  # unplan building upgrade
  def unplan_building(%Tile{construction_status: :upgrade} = state),
    do: %{state | construction_status: :none}

  # unplan building default
  def unplan_building(%Tile{} = state) do
    Logger.warn("Tile.unplan_building/1 missing clause, state: #{inspect(state)}")
    state
  end

  # put building on empty tile
  def put_building(%Tile{construction_status: :new} = state),
    do: %{state | construction_status: :none, building_status: :built, building_level: 1}

  # upgrade building
  def put_building(%Tile{construction_status: :upgrade} = state),
    do: %{state | construction_status: :none, building_status: :built, building_level: state.building_level + 1}

  # put building default
  def put_building(%Tile{} = state) do
    Logger.warn("Tile.put_building/1 missing clause, state: #{inspect(state)}")
    state
  end

  # remove building (only if cs is clear)
  def remove_building(%Tile{construction_status: :none} = state),
    do: %{state | building_status: :empty, building_key: nil, building_level: nil}

  # remove building default
  def remove_building(%Tile{} = state) do
    Logger.warn("Tile.remove_building/1 missing clause, state: #{inspect(state)}")
    state
  end

  # plan repair building (only if cs is clear)
  def plan_repair_building(%Tile{construction_status: :none, building_status: :damaged} = state),
    do: %{state | construction_status: :repair}

  # plan_repair building default
  def plan_repair_building(%Tile{} = state) do
    Logger.warn("Tile.plan_repair_building/1 missing clause, state: #{inspect(state)}")
    state
  end

  # unplan repair building
  def unplan_repair_building(%Tile{construction_status: :repair} = state),
    do: %{state | construction_status: :none}

  # unplan_repair building default
  def unplan_repair_building(%Tile{} = state) do
    Logger.warn("Tile.unplan_repair_building/1 missing clause, state: #{inspect(state)}")
    state
  end

  # damage building
  def damage_building(%Tile{construction_status: :none, building_status: :built} = state),
    do: %{state | building_status: :damaged}

  # damage building default
  def damage_building(%Tile{} = state) do
    Logger.warn("Tile.damage_building/1 missing clause, state: #{inspect(state)}")
    state
  end

  # repair building
  def repair_building(%Tile{construction_status: :repair, building_status: :damaged} = state),
    do: %{state | building_status: :built, construction_status: :none}

  # repair building default
  def repair_building(%Tile{} = state) do
    Logger.warn("Tile.repair_building/1 missing clause, state: #{inspect(state)}")
    state
  end

  def obfuscate(%Tile{} = state, visibility_level) do
    if visibility_level < 2 do
      %{
        state
        | construction_status: :hidden,
          building_status: :hidden,
          building_key: :hidden,
          building_level: :hidden
      }
    else
      case visibility_level do
        2 -> %{state | construction_status: :hidden, building_level: :hidden, building_key: :hidden}
        3 -> %{state | construction_status: :hidden, building_level: :hidden, building_key: :hidden}
        4 -> %{state | construction_status: :hidden, building_level: :hidden}
        5 -> state
      end
    end
  end
end
