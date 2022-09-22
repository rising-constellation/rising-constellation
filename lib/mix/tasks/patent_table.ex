defmodule Mix.Tasks.PatentTable do
  use Mix.Task

  @doc """
  To automatically generate all the tables and update the gist:
  #!/bin/bash
  cd ~/repositories/game
  mix compile
  mix lex_table fast fr > lex_flash.txt
  mix lex_table medium fr > lex_tactic.txt
  mix patent_table fast fr > brevets_flash.txt
  mix patent_table fast fr > brevets_tactic.txt

  gist -u bc44f316a803c7a2cb4b96b003705947 lex_flash.txt lex_tactic.txt brevets_flash.txt brevets_tactic.txt
  """

  @mod %{
    "fast" => Data.Game.Patent.Content.Fast,
    "medium" => Data.Game.Patent.Content.Medium,
    "slow" => Data.Game.Patent.Content.Slow
  }

  @head [
    ~s({| class="article-table" | width="100%"),
    ~s(! Catégorie),
    ~s(! Nom),
    ~s(! Description),
    ~s(! Coût),
    ~s(! Prérequis),
    ~s(! Effet)
  ]
  @tail "|}"

  def run([speed, lang]) do
    # buildings =
    #   get_json("front/src/locales/#{lang}/data.json")["data"]["building"]
    #   |> transform("name")
    # images: https://rising-constellation.com/portal/data/buildings/university_open.jpg
    # https://rising-constellation.com/portal/data/patents/university_open.jpg

    patents_name =
      get_json("front/src/locales/#{lang}/data.json")["data"]["patent"]
      |> transform("name")
      |> Enum.filter(fn {_k, v} -> not Enum.member?(["[INACTIF]", "[UNAVAILABLE]"], v) end)

    patents_description =
      get_json("front/src/locales/#{lang}/data.json")["data"]["patent"]
      |> transform("description")

    patent_classes =
      get_json("front/src/locales/#{lang}/data.json")["data"]["patent_class"]
      |> transform("name")

    patent_info =
      get_json("front/src/locales/#{lang}/data.json")["data"]["patent_info"]
      |> transform

    buildings_name =
      get_json("front/src/locales/#{lang}/data.json")["data"]["building"]
      |> transform("name")

    data =
      @mod[speed].data()
      |> Enum.map(fn %Data.Game.Patent{ancestor: ancestor, key: key, cost: cost, class: class, unlock: unlock} ->
        [
          patent_classes[class],
          patents_name[key],
          patents_description[key],
          cost,
          patents_name[ancestor],
          unlocks(key, unlock, patent_info, buildings_name)
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

  defp transform(table) do
    table |> Enum.into(%{}, fn {k, v} -> {String.to_atom(k), v} end)
  end

  defp transform(table, key) do
    table |> Enum.into(%{}, fn {k, v} -> {String.to_atom(k), v[key]} end)
  end

  defp get_json(filename) do
    with {:ok, body} <- File.read(filename), {:ok, json} <- Poison.decode(body) do
      json
    end
  end

  defp unlocks(key, unlock, patent_info, buildings_name) do
    list =
      unlock
      |> Enum.map(fn %{key: key} ->
        buildings_name[key]
      end)
      |> Enum.filter(&(not is_nil(&1)))
      |> Enum.map(&"[[#{&1}]]")

    if Enum.empty?(list) do
      patent_info[key]
    else
      "#{patent_info[key]}\n* Débloque #{Enum.join(list, "\n* Débloque ")}"
    end
  end
end
