# Derived from: https://github.com/adobe/bot_army/blob/68369a846d13e4ff973fdbc5decd418cc6e80f43/LICENSE
# MIT License © Copyright 2020 Adobe. All rights reserved.

defmodule SystemAI.Actions do
  @moduledoc """
  Dominion Actions.

  Actions are functions that take the bot's context and any supplied arguments,
  perform some useful side effects, and then return the outcome.  The context is
  always passed as the first argument.

  Valid outcomes are: `:succeed`, `:fail`, `:continue`, `:done` or `{:error,
  reason}`.

  `:succeed`, `:fail`, and `:continue` can also be in the form of
  `{:succeed, key: "value"}` if you want save/update the context.

  Export Actions:
    `mix extract_actions --actions-dir lib/game/system_ai/`
     Then, copy the array and paste it in the import module in the BT editor.
  """

  alias SystemAI.Helper

  @doc """
  A semantic helper to define actions in the behavior tree.

      Node.sequence([
        ...
        action(SystemAI.Actions, :wait, [5]),
        ...
        action(SystemAI.Actions, :done)
      ])
  """
  def action(module, fun, args \\ []) do
    {module, fun, args}
  end

  @doc """
  Succeed with probability `succeed_rate`
  """
  def succeed_rate({_context, state}, succeed_rate) do
    r = Game.call(state.instance_id, :rand, :master, {:uniform})
    if r <= succeed_rate, do: :succeed, else: :fail
  end

  @doc """
  Choose a random category of building to produce
  """
  def choose_category(
        {%{system_value: system_value, stellar_body_id: sb_id} = _context, %{ai_profile: profile_key} = state},
        biome_key
      ) do
    body = Helper.get_body(state, sb_id)

    # get a ratio between 0 and 1 for each categories
    k = Helper.get_categories_proportion_built(body, biome_key, system_value, state.instance_id)
    p_base = Helper.get_profile_probabilities(profile_key)
    cumulated_probabilities = Helper.get_cumulated_probabilities(p_base, k)

    # draw random [0,1[
    r = Game.call(state.instance_id, :rand, :master, {:uniform})
    # find corresponding category
    random_category = Helper.get_random_category(cumulated_probabilities, r)

    {:succeed, %{category: random_category}}
  end

  @doc """
  Stop the bot from running
  """
  def done({_, state}), do: {:done, state}

  @doc """
  Signal that this bot has errored, causing the bot's process to die with the given
  reason.
  """
  def error(_, reason), do: {:error, reason}

  @doc """
  Check if building not built in current body in tree context.
  """
  def has_not_building?({%{stellar_body_id: sb_id} = _context, state}, building_atom) do
    body = Helper.get_body(state, sb_id)

    if Helper.has_building?(body.tiles, building_atom),
      do: :fail,
      else: :succeed
  end

  @doc """
  Check if building not built n times in current body in tree context.
  """
  def has_not_n_building?({%{stellar_body_id: sb_id} = _context, state}, building_atom, n) do
    body = Helper.get_body(state, sb_id)

    if Helper.has_n_building?(body.tiles, building_atom, n),
      do: :fail,
      else: :succeed
  end

  @doc """
  Returns the uid of a random body or the main body.
  It returns the main body if the dominion built on strictly less than 4 tiles.
  Otherwise, it returns a random body.
  """
  def get_main_body({_context, state}, type \\ :open) do
    case Helper.get_main_body(state, 4, type) do
      nil ->
        :fail

      main_body ->
        biome = Helper.body_type_to_biome_key(main_body.type)
        {:succeed, %{stellar_body_id: main_body.uid, biome: biome}}
    end
  end

  @doc """
  Returns a random body within the system.
  """
  def get_random_body({_context, state}) do
    bodies =
      Helper.get_bodies(state)
      |> Helper.filter_free_bodies()

    case bodies do
      # system built fully
      [] ->
        {:done, state}

      [_ | _] ->
        random_body = Game.call(state.instance_id, :rand, :master, {:random, bodies})
        biome = Helper.body_type_to_biome_key(random_body.type)
        {:succeed, %{stellar_body_id: random_body.uid, biome: biome}}
    end
  end

  @doc """
  Builds a building on a random tile
  """
  def build({context, state}, building_atom) do
    body = Helper.get_body(state, context.stellar_body_id)
    tiles = Helper.get_free_tiles(body)
    random_tile = Game.call(state.instance_id, :rand, :master, {:random, tiles})
    production_data = {context.stellar_body_id, random_tile.id, building_atom, 1}

    Helper.build(state, production_data)
  end

  @doc """
  Build a building on the first tile.

  Used for the `:infrastructure` buildings
  """
  def build({context, state}, building_atom, tile_id) do
    Helper.build(state, {context.stellar_body_id, tile_id, building_atom, 1})
  end

  @doc """
  Build a random building within a category
  """
  def build_random({%{system_value: system_value, category: category_key} = context, state}, biome_key) do
    body = Helper.get_body(state, context.stellar_body_id)

    case Helper.get_random_building(state.instance_id, category_key, biome_key, body, system_value) do
      nil -> :fail
      building_struct -> build({context, state}, building_struct.key)
    end
  end

  @doc """
  Build or upgrade a random building within a category.
  It does not consider the body in the context.
  """
  def upgrade_random({%{category: category_key} = _context, state}) do
    bodies = Helper.get_bodies(state)

    with upgradable_tiles when upgradable_tiles != [] <-
           Helper.get_upgradable_tiles(bodies, state.instance_id, category_key),
         random_tile = Game.call(state.instance_id, :rand, :master, {:random, upgradable_tiles}),
         production_data =
           {random_tile.body_id, random_tile.id, random_tile.building_key, random_tile.building_level + 1},
         {:ok, updated_state} <- Instance.StellarSystem.StellarSystem.order_building_production(state, production_data) do
      {:done, updated_state}
    else
      {:error, reason} -> {:error, reason}
      [] -> :fail
    end
  end

  @doc """
  Randomly returns `:succeed` with probability p if the dominion value is greater than `min_value`.
  """
  def succeed_upgrade?({%{system_value: system_value} = _context, state}, p, min_value) do
    r = Game.call(state.instance_id, :rand, :master, {:uniform})

    if r < p and system_value >= min_value,
      do: :succeed,
      else: :fail
  end

  @doc """
  Check if the body's biome in the context is equal to `biome_key`
  """
  def body_belongs_to_biome?({%{stellar_body_id: _sb_id, biome: biome} = _context, _state}, biome_key) do
    cond do
      biome_key == :open and biome == :open -> :succeed
      biome_key == :dome and biome == :dome -> :succeed
      biome_key == :orbital and biome == :orbital -> :succeed
      true -> :fail
    end
  end

  @doc """
  Succeed if the system potential workforce is lower than `workforce_threshold`
  """
  def workforce_needed?({_context, state}, workforce_threshold) do
    if state.workforce - state.used_workforce <= workforce_threshold,
      do: :succeed,
      else: :fail
  end

  @spec happiness_needed?({any, atom | %{happiness: atom | %{value: any}}}, any) :: :fail | :succeed
  @doc """
  Succeed if the system happiness is lower than `happiness_threshold`
  """
  def happiness_needed?({_context, state}, happiness_threshold) do
    if state.happiness.value <= happiness_threshold,
      do: :succeed,
      else: :fail
  end

  @doc """
  Succeed if the dominion built an :infra on a open or dome biome
  """
  def build_random_infra({_context, state}) do
    bodies = Helper.get_bodies_no_infra(state)

    case bodies do
      [] ->
        :fail

      bodies ->
        body = Game.call(state.instance_id, :rand, :master, {:random, bodies})
        prod_key = if body.type == :habitable_planet, do: :infra_open, else: :infra_dome
        Helper.build(state, {body.uid, 1, prod_key, 1})
    end
  end

  @doc """
  Succeed if the dominion built a workforce building.

  Builds workforce on `:open` or `:dome` biomes.
  """
  def build_workforce({_context, state}) do
    bodies =
      Helper.get_bodies(state)
      |> Helper.filter_free_bodies()
      |> Enum.filter(&(&1.type in [:open, :dome]))

    case bodies do
      [] ->
        :fail

      bodies ->
        body = Game.call(state.instance_id, :rand, :master, {:random, bodies})
        tile = Game.call(state.instance_id, :rand, :master, {:random, body.tiles})
        prod_key = Helper.get_workforce_building_key(state.instance_id, body.type)
        Helper.build(state, {body.uid, tile.id, prod_key, 1})
    end
  end

  @doc """
  Succeed if the dominion built a happinness building.
  """
  def build_happiness({%{system_value: system_value} = _context, state}) do
    bodies =
      Helper.get_bodies(state)
      |> Helper.filter_free_bodies()
      |> Helper.filter_full_happiness_bodies(state.instance_id)

    case bodies do
      [] ->
        :fail

      bodies ->
        body = Game.call(state.instance_id, :rand, :master, {:random, bodies})
        free_tiles = Helper.get_free_tiles(body)
        already_built_keys = Enum.map(free_tiles, & &1.building_key)

        buildings =
          body
          |> Helper.get_happiness_buildings(state.instance_id, already_built_keys)
          |> Helper.filter_buildings_by_system_value(system_value)

        if Enum.any?(buildings) do
          tile = Game.call(state.instance_id, :rand, :master, {:random, free_tiles})
          building = Game.call(state.instance_id, :rand, :master, {:random, buildings})
          Helper.build(state, {body.uid, tile.id, building.key, 1})
        else
          :fail
        end
    end
  end

  @doc """
  Succeed if the dominion has an element in its production queue.
  """
  def wait_if_queue_is_busy({_context, state}) do
    if not Queue.empty?(state.queue.queue), do: {:done, state}, else: :fail
  end

  @doc """
  Succeed if the dominion has a correct growth and not yet available workforce slots.
  """
  def wait_for_population_growth({_context, state}, workforce_threshold) do
    if state.habitation.value - state.used_workforce >= workforce_threshold and
         state.workforce - state.used_workforce <= 1 and
         state.population.change > 0.5,
       do: {:done, state},
       else: :fail
  end

  @doc """
  Succeed if one building was repaired.
  """
  def repair_if_needed({_context, state}) do
    tiles =
      Helper.get_bodies(state)
      |> Helper.get_damaged_tiles()

    with true <- length(tiles) > 0,
         tile <- Game.call(state.instance_id, :rand, :master, {:random, tiles}),
         production_data = {tile.body_id, tile.id, nil, nil},
         {:ok, state} <- Instance.StellarSystem.StellarSystem.order_building_repairs(state, production_data) do
      {:done, state}
    else
      _ ->
        :fail
    end
  end
end
