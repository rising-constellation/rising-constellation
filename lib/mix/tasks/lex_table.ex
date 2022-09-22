defmodule Mix.Tasks.LexTable do
  use Mix.Task

  @mod %{
    "fast" => Data.Game.Doctrine.Content.Fast,
    "medium" => Data.Game.Doctrine.Content.Medium,
    "slow" => Data.Game.Doctrine.Content.Slow
  }

  @head [
    ~s({| class="article-table" | width="100%""),
    ~s(! Catégorie),
    ~s(! Nom),
    ~s(! Description),
    ~s(! Coût),
    ~s(! Prérequis),
    ~s(! Effet)
  ]
  @tail "|}"

  def run([speed, lang]) do
    dotrines_name =
      get_json("front/src/locales/#{lang}/data.json")["data"]["doctrine"]
      |> transform("name")
      |> Enum.filter(fn {_k, v} -> not Enum.member?(["[INACTIF]", "[UNAVAILABLE]"], v) end)

    dotrines_description =
      get_json("front/src/locales/#{lang}/data.json")["data"]["doctrine"]
      |> transform("description")

    dotrines_quotes =
      get_json("front/src/locales/#{lang}/data.json")["data"]["doctrine"]
      |> transform("quote")

    doctrine_classes =
      get_json("front/src/locales/#{lang}/data.json")["data"]["doctrine_class"]
      |> transform("name")

    bonus_in =
      get_json("front/src/locales/#{lang}/data.json")["data"]["bonus_pipeline_in"]
      |> transform("name")

    bonus_out =
      get_json("front/src/locales/#{lang}/data.json")["data"]["bonus_pipeline_out"]
      |> transform("name")

    data =
      @mod[speed].data()
      |> Enum.map(fn %Data.Game.Doctrine{ancestor: ancestor, key: key, cost: cost, class: class, bonus: bonus} ->
        [
          doctrine_classes[class],
          dotrines_name[key],
          dotrines_quotes[key],
          cost,
          dotrines_name[ancestor],
          bonuses(bonus, bonus_in, bonus_out, dotrines_description[key])
        ]
      end)
      |> Enum.filter(fn [a, b | _tail] -> a && b end)
      |> Enum.map(&Enum.join(&1, "\n| "))
      # |> Enum.slice(1..5)
      |> Enum.join("\n|-\n| ")

    contents = ["|-\n| ", data] |> Enum.join()

    [Enum.join(@head, "\n"), contents, @tail]
    |> Enum.join("\n")
    |> IO.puts()
  end

  def run(_) do
    [
      ["fast", "fr"],
      ["medium", "fr"]
      # ["slow", "fr"],
      # ["fast", "en"],
      # ["medium", "en"],
      # ["slow", "en"],
    ]
    |> Enum.each(fn arg ->
      IO.puts(inspect(arg))
      IO.puts("\n")
      run(arg)
      IO.puts("\n")
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

  defp bonuses(bonus, bonus_in, bonus_out, _desc) do
    list =
      bonus
      |> Enum.map(fn
        %{from: :direct, to: to, value: value} when value >= 0 ->
          "#{bonus_out[to]} +#{value}"

        %{from: :direct, to: to, value: value} when value < 0 ->
          "#{bonus_out[to]} #{value}"

        %{from: to, to: to, value: value, type: :mul} when value >= 0 ->
          "#{bonus_out[to]} +#{value * 100}%"

        %{from: to, to: to, value: value, type: :mul} when value < 0 ->
          "#{bonus_out[to]} #{value * 100}%"

        %{from: from, to: to, value: value, type: :mul} ->
          "#{bonus_out[to]} = #{bonus_out[to]} + (#{bonus_in[from]} × #{value})"
      end)

    if Enum.empty?(list) do
      ""
    else
      "\n* #{Enum.join(list, "\n* ")}"
    end
  end
end
