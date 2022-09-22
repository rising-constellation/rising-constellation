defmodule SystemAI.Helper do
  alias SystemAI.BuildingsHelper

  def profiles() do
    [:production, :credit, :technologic, :ideologic, :defense]
  end

  def get_workforce_range(system_value) do
    cond do
      system_value >= 0 and system_value < 8 -> 0..2
      system_value >= 8 and system_value < 18 -> 2..4
      system_value >= 18 -> 3..6
    end
  end

  # Probabilities
  ################

  @doc """
  Return tuple of 5 probabilities that match a category. The sum is 1.
  The order is [p_prod, p_cred, p_ideo, p_techno, p_defense}
  """
  def get_profile_probabilities(profile_key) do
    probabilities =
      case profile_key do
        :balanced -> [1 / 5, 1 / 5, 1 / 5, 1 / 5, 1 / 5]
        :production -> [1 / 2, 1 / 8, 1 / 8, 1 / 8, 1 / 8]
        :credit -> [1 / 8, 1 / 2, 1 / 8, 1 / 8, 1 / 8]
        :technologic -> [1 / 8, 1 / 8, 1 / 2, 1 / 8, 1 / 8]
        :ideologic -> [1 / 8, 1 / 8, 1 / 8, 1 / 2, 1 / 8]
        :defense -> [1 / 8, 1 / 8, 1 / 8, 1 / 8, 1 / 2]
      end

    Enum.zip([:production, :credit, :technologic, :ideologic, :defense], probabilities)
  end

  @doc """
  Compute a shifted distribution based on `p_base` and the map of ratios `k_values`.
  If k is 1 the corresponding category in `p_base` is not considered.
  """
  def get_cumulated_probabilities(p_base, k_values) do
    # shift with k values
    shifted_probabilities =
      Enum.zip(p_base, k_values)
      |> Enum.map(fn {{category, p_base}, {_category, k}} -> {category, (1 - k) * p_base} end)
      |> Enum.filter(fn {_category, p} -> p != 0 end)

    # sum of new density
    sum_shifted_probabilities = Enum.reduce(shifted_probabilities, 0, fn {_category, p}, acc -> p + acc end)

    # normalize to have the sum equal to 1
    normalized_shifted_probabilities =
      Enum.map(shifted_probabilities, fn {category, p} -> {category, p / sum_shifted_probabilities} end)

    # compute cumulated probabilities
    normalized_shifted_probabilities
    |> Enum.scan(fn {category, p}, {_c, p_prev} -> {category, p + p_prev} end)
  end

  @doc """
  With the list of cumulated probabilities and a random variable r in [0,1[, draws a random building category.
  """
  def get_random_category(cumulated_probabilities, r) do
    Enum.reduce(cumulated_probabilities, nil, fn {category, p}, category_acc ->
      if r < p and category_acc == nil,
        do: category,
        else: category_acc
    end)
  end

  @doc """
  Get a random building. The buildings are filtered by the profile, the system value and biome.
  """
  def get_random_building(instance_id, profile_key, biome_key, body, system_value) do
    filtered_buildings =
      BuildingsHelper.get_biome_buildings(biome_key, instance_id)
      |> filter_buildings_by_system_value(system_value)
      |> filter_building_by_profile(profile_key)
      |> filter_already_built_unique_buildings(instance_id, body)

    if Enum.empty?(filtered_buildings),
      do: nil,
      else: Game.call(instance_id, :rand, :master, {:random, filtered_buildings})
  end

  @doc """
  Filters the buildings by profile.

  The `profile` atom is mapped to an atom of the %Building{} struct.
  """
  def filter_building_by_profile(buildings, profile) do
    building_output =
      case profile do
        :production -> :prod
        :credit -> :credit
        :technologic -> :tech
        :ideologic -> :ideo
        :defense -> :defense
      end

    buildings
    |> Enum.filter(fn building ->
      building_output in building.outputs
    end)
  end

  @doc """
  Returns a ratio for each building category. If the ratio is 1, the dominion will not consider the category.

  The buildings are filtered by the system value.
  """
  def get_categories_proportion_built(body, biome_key, system_value, instance_id) do
    buildings =
      BuildingsHelper.get_biome_buildings(biome_key, instance_id)
      |> filter_buildings_by_system_value(system_value)

    length_production_buildings = buildings |> filter_building_by_profile(:production) |> length()
    length_credit_buildings = buildings |> filter_building_by_profile(:credit) |> length()
    length_techno_buildings = buildings |> filter_building_by_profile(:technologic) |> length()
    length_ideologic_buildings = buildings |> filter_building_by_profile(:ideologic) |> length()
    length_defense_buildings = buildings |> filter_building_by_profile(:defense) |> length()

    {n_productions, n_credits, n_technologics, n_ideologics, n_defenses} = count_buildings(body, buildings)

    ratio_productions = get_ratio(n_productions, length_production_buildings)
    ratio_credits = get_ratio(n_credits, length_credit_buildings)
    ratio_technologics = get_ratio(n_technologics, length_techno_buildings)
    ratio_ideologics = get_ratio(n_ideologics, length_ideologic_buildings)
    ratio_defenses = get_ratio(n_defenses, length_defense_buildings)

    [
      production: ratio_productions,
      credit: ratio_credits,
      technologic: ratio_technologics,
      ideologic: ratio_ideologics,
      defense: ratio_defenses
    ]
  end

  defp get_ratio(count, length) do
    cond do
      # no building in category built
      length == 0 -> 1
      # buildings in category built but some are duplicates
      length >= 1 -> 1 / 2
      # normal computation
      true -> count / length
    end
  end

  # Bodies
  ################

  def get_bodies(stellar_system) do
    Enum.flat_map(
      stellar_system.bodies,
      fn body ->
        get_nested_bodies(body) ++
          if not Enum.empty?(body.tiles),
            do: [
              %{
                uid: body.uid,
                type: body.type,
                tiles: body.tiles
              }
            ],
            else: []
      end
    )
  end

  defp get_nested_bodies(body) do
    Enum.map(body.bodies, fn nested_body ->
      %{
        uid: nested_body.uid,
        type: nested_body.type,
        tiles: nested_body.tiles
      }
    end)
  end

  def get_body(system, stellar_body_id) do
    [body] =
      system
      |> get_bodies()
      |> Enum.filter(fn body -> body.uid == stellar_body_id end)

    body
  end

  def get_bodies_no_infra(system) do
    system
    |> get_bodies()
    |> Enum.filter(fn body -> body.type == :habitable_planet or body.type == :sterile_planet end)
    |> Enum.filter(fn body -> hd(body.tiles).building_status == :empty end)
  end

  def filter_free_bodies(bodies) do
    Enum.filter(bodies, fn body ->
      free_tile?(body)
    end)
  end

  def filter_bodies(bodies, body_type) do
    Enum.filter(bodies, fn body -> body.type == body_type end)
  end

  @doc """
  Filter the bodies that have all the happiness buildings already built.
  """
  def filter_full_happiness_bodies(bodies, instance_id) do
    Enum.filter(bodies, fn body ->
      building_keys =
        get_built_tiles(body)
        |> Enum.map(fn tile -> tile.building_key end)

      eligible_buildings = get_happiness_buildings(body, instance_id, building_keys)

      # true if not all buildings of eligible buildings are in buildings_keys
      not Enum.all?(eligible_buildings, fn prod_key -> Enum.member?(building_keys, prod_key) end)
    end)
  end

  @doc """
  Map a body type to its corresponding biome.
  """
  def body_type_to_biome_key(body_type) do
    case body_type do
      :habitable_planet -> :open
      :sterile_planet -> :dome
      :moon -> :orbital
      :asteroid -> :orbital
    end
  end

  @doc """
   Returns the uid of a habitable planet with a megapole

   Returns `nil` if not found
  """
  def get_main_body(system, max_tiles, biome \\ :open) do
    {body_type, main_infra} =
      if biome == :open,
        do: {:habitable_planet, :infra_open},
        else: {:sterile_planet, :infra_dome}

    bodies =
      get_bodies(system)
      |> filter_bodies(body_type)
      |> Enum.filter(fn body -> has_building?(body.tiles, main_infra) end)
      |> Enum.filter(fn body -> free_tile?(body) end)

    # in case of multiple bodies with a megapole, choose random
    case bodies do
      [] ->
        nil

      [body] ->
        # Return only if less than max_tiles tiles are taken
        free_tiles = get_free_tiles(body)

        if length(free_tiles) > max_tiles,
          do: body,
          else: nil

      [_ | _] ->
        nil
    end
  end

  # Tiles
  ################

  def free_tile?(body) do
    Enum.any?(body.tiles, fn tile -> tile.building_status == :empty end)
  end

  def get_free_tiles(body) do
    Enum.filter(body.tiles, fn tile -> tile.building_status == :empty end)
  end

  def get_built_tiles(body) do
    Enum.filter(body.tiles, fn tile -> tile.building_status == :built end)
  end

  def get_damaged_tiles(bodies) do
    Enum.flat_map(bodies, fn body ->
      body.tiles
      |> Enum.filter(&(&1.building_status == :damaged))
      |> Enum.map(fn tile -> Map.merge(tile, %{body_id: body.uid}) end)
    end)
  end

  @doc """
  Returns the tiles within a category that are upgradable.
  """
  def get_upgradable_tiles(bodies, instance_id, category_key) do
    # get built tiles of our bodies
    built_tiles_with_body_id =
      Enum.flat_map(bodies, fn body ->
        body.tiles
        |> Enum.filter(&(&1.building_status == :built))
        |> Enum.map(fn tile -> Map.merge(tile, %{body_id: body.uid}) end)
      end)

    # get all buildings of the category `category_key`
    eligible_buildings =
      BuildingsHelper.get_all_buildings(instance_id)
      |> filter_building_by_profile(category_key)
      |> Enum.map(& &1.key)

    # built tiles should be in `eligible_buildings` and should not have reached their max lvl
    Enum.filter(built_tiles_with_body_id, fn tile ->
      max_lvl = get_building_max_level(tile.building_key, instance_id)
      tile.building_level < max_lvl and Enum.member?(eligible_buildings, tile.building_key)
    end)
  end

  # Building
  ################

  def enough_workforce?(state, {_body_id, _tile, prod_key, _level}) do
    building = Enum.find(BuildingsHelper.get_all_buildings(state.instance_id), &(&1.key == prod_key))
    state.workforce - state.used_workforce >= building.workforce
  end

  def build(state, production_data) do
    with true <- enough_workforce?(state, production_data),
         {:ok, updated_state} <- Instance.StellarSystem.StellarSystem.order_building_production(state, production_data) do
      {:done, updated_state}
    else
      false ->
        {:done, state}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Returns a random workforce building depending of the biome.
  """
  def get_workforce_building_key(instance_id, biome) do
    buildings =
      BuildingsHelper.get_biome_buildings(biome, instance_id)
      |> Enum.filter(fn %{type: type, outputs: outputs} -> type === :normal and :hab in outputs end)
      |> Enum.map(fn b -> b.key end)

    Game.call(instance_id, :rand, :master, {:random, buildings})
  end

  @doc """
  Returns buildings that produce happiness.
  """
  def get_happiness_buildings(body, instance_id, already_built_keys) do
    body_type_to_biome_key(body.type)
    |> BuildingsHelper.get_biome_buildings(instance_id)
    |> Enum.filter(fn %{outputs: outputs} -> :happiness in outputs end)
    |> Enum.filter(fn %{key: key} -> not Enum.member?(already_built_keys, key) end)
  end

  def has_building?(tiles, building_atom) do
    Enum.any?(tiles, fn tile -> tile.building_key == building_atom end)
  end

  def has_n_building?(tiles, building_atom, n) do
    Enum.count(tiles, fn tile -> tile.building_key == building_atom end) >= n
  end

  @doc """
  Filters the buildings with the `system_value` value of the system.
  """
  def filter_buildings_by_system_value(buildings, system_value) do
    range = get_workforce_range(system_value)

    buildings
    |> Enum.filter(fn building ->
      Enum.member?(range, building.workforce)
    end)
  end

  @doc """
  Returns tuple with the count of buildings for the 5 categories: neutral, technologic and ideologic.
  """
  def count_buildings(body, buildings) do
    Enum.reduce(body.tiles, {0, 0, 0, 0, 0}, fn tile, acc ->
      with true <- tile.building_key != nil,
           building_struct <- Enum.find(buildings, &(&1.key == tile.building_key)),
           true <- building_struct != nil do
        building_outputs = building_struct.outputs

        Enum.reduce(building_outputs, acc, fn building_output, {acc_prod, acc_cred, acc_techno, acc_ideo, acc_def} ->
          case building_output do
            :prod -> {acc_prod + 1, acc_cred, acc_techno, acc_ideo, acc_def}
            :hab -> {acc_prod + 1, acc_cred, acc_techno, acc_ideo, acc_def}
            :credit -> {acc_prod, acc_cred + 1, acc_techno, acc_ideo, acc_def}
            :tech -> {acc_prod, acc_cred, acc_techno + 1, acc_ideo, acc_def}
            :ideo -> {acc_prod, acc_cred, acc_techno, acc_ideo + 1, acc_def}
            :defense -> {acc_prod, acc_cred, acc_techno, acc_ideo, acc_def + 1}
            :happiness -> {acc_prod, acc_cred, acc_techno, acc_ideo, acc_def}
          end
        end)
      else
        _ -> acc
      end
    end)
  end

  def get_building_limitation(building_key, instance_id) do
    Data.Querier.one(Data.Game.Building, instance_id, building_key).limitation
  end

  def get_building_max_level(building_key, instance_id) do
    building_data = Data.Querier.one(Data.Game.Building, instance_id, building_key)
    buildings_levels = Enum.map(building_data.levels, fn level_data -> level_data.level end)
    Enum.max(buildings_levels)
  end

  def filter_already_built_unique_buildings(buildings, instance_id, body) do
    buildings_on_body =
      Enum.map(body.tiles, fn tile -> tile.building_key end)
      |> Enum.filter(&(&1 != nil))

    Enum.filter(buildings, fn %{key: building} ->
      on_body? = Enum.any?(buildings_on_body, fn building_on_body -> building_on_body == building end)
      limitation = get_building_limitation(building, instance_id)

      not (on_body? and limitation == :unique)
    end)
  end
end
