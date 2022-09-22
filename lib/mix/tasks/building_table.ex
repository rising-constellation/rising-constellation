defmodule Mix.Tasks.BuildingTable do
  use Mix.Task

  @doc """
  To automatically generate all the tables and update the gist:
  #!/bin/bash
  cd ~/repositories/game
  mix compile

  mix building_table fr > building_table.txt
  gist -u f281f6ae478437a167a502c788e915a6 building_table.txt
  """

  @mod %{
    "Flash" => Data.Game.Building.Content.Fast,
    "Tactic" => Data.Game.Building.Content.Medium,
    "Legacy" => Data.Game.Building.Content.Slow
  }
  @tail "|}"

  def table_head(name) do
    [
      a: ~s({| class="article-table"),
      b: "|+#{name}",
      c: ~s(! Niveau),
      d: ~s(! Coût en crédit),
      e: ~s(! Coût de production),
      f: ~s(! Population mobilisée),
      g: ~s(! Habitation),
      h: ~s(! Production),
      i: ~s(! Technologie),
      j: ~s(! Idéologie),
      k: ~s(! Crédit),
      l: ~s(! Stabilité),
      m: ~s(! Mobilité),
      n: ~s(! Défense),
      o: ~s(! Radar),
      p: ~s(! Espionnage),
      p2: ~s(! Contre-espionnage),
      q: ~s(! XP Initiale des chasseurs),
      r: ~s(! XP initiale des corvettes),
      s: ~s(! XP initiale des frégates),
      t: ~s(! XP initiale des vaisseaux capitaux)
    ]
  end

  def run([lang]) do
    buildings_name =
      get_json("front/src/locales/#{lang}/data.json")["data"]["building"]
      |> transform("name")

    bonus_in =
      get_json("front/src/locales/#{lang}/data.json")["data"]["bonus_pipeline_in"]
      |> transform("name")

    Enum.reduce(@mod, %{}, fn {speed, mod}, building_to_speed ->
      mod.data()
      # |> Enum.filter(&(&1.key == :ideo_open))
      |> Enum.reduce(building_to_speed, fn %Data.Game.Building{key: key, workforce: workforce, levels: levels},
                                           building_to_speed ->
        all_levels =
          levels
          |> Enum.map(fn %{credit: credit, production: production, level: level, bonus: bonus} ->
            capital_lvl_bonus = Enum.filter(bonus, &(&1.to == :sys_capital_lvl))
            ci_bonus = Enum.filter(bonus, &(&1.to == :sys_ci))
            corvette_lvl_bonus = Enum.filter(bonus, &(&1.to == :sys_corvette_lvl))
            credit_bonus = Enum.filter(bonus, &(&1.to == :sys_credit))
            defense_bonus = Enum.filter(bonus, &(&1.to == :sys_defense))
            fighter_lvl_bonus = Enum.filter(bonus, &(&1.to == :sys_fighter_lvl))
            frigate_lvl_bonus = Enum.filter(bonus, &(&1.to == :sys_frigate_lvl))
            habitation_bonus = Enum.filter(bonus, &(&1.to == :sys_habitation))
            happiness_bonus = Enum.filter(bonus, &(&1.to == :sys_happiness))
            ideology_bonus = Enum.filter(bonus, &(&1.to == :sys_ideology))
            mobility_bonus = Enum.filter(bonus, &(&1.to == :sys_mobility))
            production_bonus = Enum.filter(bonus, &(&1.to == :sys_production))
            radar_bonus = Enum.filter(bonus, &(&1.to == :sys_radar))
            remove_contact_bonus = Enum.filter(bonus, &(&1.to == :sys_remove_contact))
            technology_bonus = Enum.filter(bonus, &(&1.to == :sys_technology))

            [
              c: level,
              d: credit,
              e: production,
              f: workforce,
              g: n_to_string(habitation_bonus, bonus_in),
              h: n_to_string(production_bonus, bonus_in),
              i: n_to_string(technology_bonus, bonus_in),
              j: n_to_string(ideology_bonus, bonus_in),
              k: n_to_string(credit_bonus, bonus_in),
              l: n_to_string(happiness_bonus, bonus_in),
              m: n_to_string(mobility_bonus, bonus_in),
              n: n_to_string(defense_bonus, bonus_in),
              o: n_to_string(radar_bonus, bonus_in),
              p: n_to_string(ci_bonus, bonus_in),
              p2: n_to_string(remove_contact_bonus, bonus_in),
              q: n_to_string(fighter_lvl_bonus, bonus_in),
              r: n_to_string(corvette_lvl_bonus, bonus_in),
              s: n_to_string(frigate_lvl_bonus, bonus_in),
              t: n_to_string(capital_lvl_bonus, bonus_in)
            ]
          end)

        acc = %{
          c: 0,
          d: 0,
          e: 0,
          f: 0,
          g: 0,
          h: 0,
          i: 0,
          j: 0,
          k: 0,
          l: 0,
          m: 0,
          n: 0,
          o: 0,
          p: 0,
          p2: 0,
          q: 0,
          r: 0,
          s: 0,
          t: 0
        }

        empty_columns =
          all_levels
          |> Enum.reduce(acc, fn kw, acc ->
            kw
            |> Enum.reduce(acc, fn
              {_k, 0}, acc -> acc
              {k, _v}, acc -> Map.update(acc, k, 0, fn n -> n + 1 end)
            end)
          end)
          |> Enum.reduce([], fn
            {k, 0}, acc -> [k | acc]
            {_k, _v}, acc -> acc
          end)

        all_levels_string =
          all_levels
          |> Enum.map(fn x -> Enum.reject(x, fn {k, _v} -> k in empty_columns end) end)
          |> Enum.map(&Keyword.values/1)
          |> Enum.map(&Enum.join(&1, "\n| "))
          |> Enum.join("\n|-\n| ")

        contents = ["|-\n| ", all_levels_string] |> Enum.join()

        clean_table_head =
          table_head(buildings_name[key])
          |> Enum.reject(fn {k, _v} -> k in empty_columns end)
          |> Keyword.values()

        table =
          [Enum.join(clean_table_head, "\n"), contents, @tail]
          |> Enum.join("\n")

        Map.update(building_to_speed, key, %{speed => table}, fn map -> Map.put(map, speed, table) end)
      end)
    end)
    |> Enum.each(fn {_building_key, speed_to_building} ->
      IO.puts("")
      IO.puts("")

      ["Flash", "Tactic", "Legacy"]
      |> Enum.each(fn speed ->
        if Map.has_key?(speed_to_building, speed) do
          IO.puts("====#{speed}====")
          IO.puts("")
          IO.puts(speed_to_building[speed])
          IO.puts("")
        end
      end)
    end)
  end

  defp transform(table, key) do
    table |> Enum.into(%{}, fn {k, v} -> {String.to_atom(k), v[key]} end)
  end

  defp get_json(filename) do
    with {:ok, body} <- File.read(filename), {:ok, json} <- Poison.decode(body) do
      json
    end
  end

  def n_to_string([], _bonus_in), do: 0
  def n_to_string([bonus], bonus_in), do: "#{n_to_string(bonus, bonus_in)}"
  def n_to_string([bonus | tail], bonus_in), do: "#{n_to_string(bonus, bonus_in)}\n#{n_to_string(tail, bonus_in)}"

  def n_to_string(%{from: :direct, value: value}, _bonus_in) do
    if value >= 0 do
      "+#{value}"
    else
      "#{value}"
    end
  end

  def n_to_string(%{from: from, value: value}, bonus_in) do
    "#{bonus_in[from]} × #{value}"
  end
end
