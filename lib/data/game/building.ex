defmodule Data.Game.Building do
  use TypedStruct
  use Util.MakeEnumerable

  def jason(), do: [except: [:outputs]]

  typedstruct enforce: true do
    field(:key, atom())
    field(:biome, atom())
    field(:type, atom())
    field(:display, atom())
    field(:limitation, atom())
    field(:workforce, integer())
    field(:outputs, [])
    field(:illustration, String.t())
    field(:levels, [])
  end

  def specs do
    "Elixir." <> module = Atom.to_string(__MODULE__)
    module = "#{module}.Content"

    [
      %{
        metadata: [speed: :fast],
        content_name: "building-fast",
        module: module <> ".Fast",
        sources: {"1QFhTWcat_IBQ49cpayBZLja1SsWWxxBNGYsf7tNrhWE", "building"}
      },
      %{
        metadata: [speed: :medium],
        content_name: "building-medium",
        module: module <> ".Medium",
        sources: {"1npyGc-dqkiUWOvXOxcbURJ6YxQNcD71uJetmEbvYRzI", "building"}
      },
      %{
        metadata: [speed: :slow],
        content_name: "building-slow",
        module: module <> ".Slow",
        sources: {"1vIR5EilO5e8pqOTJx6rsJbjr2tiib2FrGtmLG1hvGK0", "building"}
      }
    ]
  end

  def csv_to_struct(_header, data, _metadata) do
    Enum.map(data, fn line ->
      [
        key,
        illu,
        biome,
        type,
        display,
        limitation,
        workforce,
        outputs,
        patent,
        max_level,
        pmin,
        pmax,
        pf,
        cmin,
        cmax,
        cf | _rest
      ] = line

      max_level = Data.Util.parse_int(max_level)
      pmin = Data.Util.parse_number(pmin)
      pmax = Data.Util.parse_number(pmax)
      cmin = Data.Util.parse_number(cmin)
      cmax = Data.Util.parse_number(cmax)

      levels =
        Enum.map(1..max_level, fn level ->
          {patent, hide_patent?} =
            cond do
              level == 1 -> {patent, false}
              type == ":infrastructure" -> {"#{String.slice(patent, 0..-2)}#{level}", false}
              biome == ":orbital" -> {":infra_orbital_#{level}", true}
              true -> {"nil", false}
            end

          patent = Data.Util.parse_atom(patent)
          production = value_by_level(level, max_level, pmin, pmax, pf)
          credit = value_by_level(level, max_level, cmin, cmax, cf)

          bonus =
            Enum.reduce(1..4, [], fn index, acc ->
              row = 16 + (index - 1) * 5

              from = Enum.at(line, row)
              to = Enum.at(line, row + 1)
              min = Data.Util.parse_number(Enum.at(line, row + 2))
              max = Data.Util.parse_number(Enum.at(line, row + 3))
              f = Enum.at(line, row + 4)

              if from == "" do
                acc
              else
                value = value_by_level(level, max_level, min, max, f)
                acc ++ [Data.Util.parse_bonus("#{from},#{value},:add,#{to}")]
              end
            end)

          %{
            level: level,
            patent: patent,
            hide_patent?: hide_patent?,
            production: production,
            credit: credit,
            bonus: bonus
          }
        end)

      %Data.Game.Building{
        key: Data.Util.parse_atom(key),
        biome: Data.Util.parse_atom(biome),
        type: Data.Util.parse_atom(type),
        display: Data.Util.parse_atom(display),
        limitation: Data.Util.parse_atom(limitation),
        workforce: Data.Util.parse_int(workforce),
        outputs: Data.Util.parse_atom_list(outputs),
        illustration: parse_illustration(illu, key),
        levels: levels
      }
    end)
  end

  defp parse_illustration("Y", key), do: "#{String.slice(key, 1..-1)}.jpg"
  defp parse_illustration(_illustration, _key), do: "default.jpg"

  defp value_by_level(level, max_level, min_value, max_value, f) do
    function = String.at(f, 0)
    precision = String.at(f, 1)

    value =
      cond do
        level == 1 ->
          min_value

        level == max_level ->
          max_value

        true ->
          case function do
            "l" ->
              factor = (level - 1) / (max_level - 1)
              (max_value - min_value) * factor + min_value

            _ ->
              steps =
                case function do
                  "a" -> [0.050, 0.300, 0.600]
                  "b" -> [0.025, 0.250, 0.550]
                  "c" -> [0.050, 0.150, 0.400]
                  "d" -> [0.125, 0.250, 0.500]
                  "e" -> [0.320, 0.520, 0.750]
                  "f" -> [0.300, 0.450, 0.650]
                  "g" -> [0.250, 0.400, 0.650]
                  "s" -> [0.600, 0.800, 0.900]
                  _ -> raise "Unknown factor function"
                end

              factor = Enum.at(steps, level - 2)
              max_value * factor
          end
      end

    case precision do
      "0" -> trunc(value)
      "1" -> :erlang.float_to_binary(value / 1, decimals: 1)
      "2" -> :erlang.float_to_binary(value / 1, decimals: 2)
    end
  end
end
