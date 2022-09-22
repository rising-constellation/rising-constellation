defmodule Data.Querier do
  # ######################## #
  # Modules names conversion #
  # ######################## #

  def modules() do
    [
      %{
        string: "constant",
        module: Data.Game.Constant,
        export: true
      },
      %{
        string: "speed",
        module: Data.Game.Speed,
        export: true
      },
      %{
        string: "calendar",
        module: Data.Game.Calendar,
        export: true
      },
      %{
        string: "culture",
        module: Data.Game.Culture,
        export: true
      },
      %{
        string: "faction",
        module: Data.Game.Faction,
        export: true
      },
      %{
        string: "stellar_body",
        module: Data.Game.StellarBody,
        export: true
      },
      %{
        string: "stellar_system",
        module: Data.Game.StellarSystem,
        export: true
      },
      %{
        string: "building",
        module: Data.Game.Building,
        export: true
      },
      %{
        string: "patent",
        module: Data.Game.Patent,
        export: true
      },
      %{
        string: "doctrine",
        module: Data.Game.Doctrine,
        export: true
      },
      %{
        string: "character",
        module: Data.Game.Character,
        export: true
      },
      %{
        string: "character-illustration",
        module: Data.Game.CharacterIllustration,
        export: false
      },
      %{
        string: "character-rank",
        module: Data.Game.CharacterRank,
        export: true
      },
      %{
        string: "bonus_pipeline_in",
        module: Data.Game.BonusPipelineIn,
        export: true
      },
      %{
        string: "bonus_pipeline_out",
        module: Data.Game.BonusPipelineOut,
        export: true
      },
      %{
        string: "ship",
        module: Data.Game.Ship,
        export: true
      },
      %{
        string: "population_status",
        module: Data.Game.PopulationStatus,
        export: true
      },
      %{
        string: "population_class",
        module: Data.Game.PopulationClass,
        export: true
      }
    ]
  end

  def module_to_string(key) do
    case Enum.find(modules(), fn m -> m.module == key end) do
      nil -> throw(:module_not_found)
      result -> result.string
    end
  end

  def string_to_module(key) do
    case Enum.find(modules(), fn m -> m.string == key end) do
      nil -> throw(:module_not_found)
      result -> result.module
    end
  end

  # ######## #
  # Metadata #
  # ######## #

  def metadatas() do
    [
      [speed: :fast, mode: :dev],
      [speed: :fast, mode: :prod],
      [speed: :medium, mode: :dev],
      [speed: :medium, mode: :prod],
      [speed: :slow, mode: :dev],
      [speed: :slow, mode: :prod]
    ]
  end

  def match_metadata_with_specs(metadata, specs) do
    spec =
      Enum.find(specs, fn spec ->
        Enum.reduce(metadata, true, fn {key, value}, acc ->
          cond do
            acc == false -> acc
            Enum.empty?(spec.metadata) -> true
            Keyword.has_key?(spec.metadata, key) -> Keyword.get(spec.metadata, key) == value
            true -> acc
          end
        end)
      end)

    if spec == nil,
      do: List.last(specs),
      else: spec
  end

  # ########## #
  # Fetch data #
  # ########## #

  def load_content(module, metadata) do
    # Get matching spec
    spec = match_metadata_with_specs(metadata, module.specs)

    apply(String.to_atom("Elixir.#{spec.module}"), :data, [])
  end

  def fetch_one(module, metadata, val) do
    fetch_one(module, metadata, :key, val)
  end

  def fetch_one(module, metadata, key, val) do
    load_content(module, metadata)
    |> Enum.find(nil, fn item ->
      {:ok, fetched_val} = Map.fetch(item, key)
      fetched_val == val
    end)
  end

  def fetch_all(module, metadata) do
    load_content(module, metadata)
  end

  def fetch_all(module, metadata, filter) do
    load_content(module, metadata)
    |> Enum.filter(fn item -> filter.(item) end)
  end

  def fetch_all(metadata) do
    Enum.reduce(modules(), %{}, fn module, acc ->
      Map.put(acc, module.module, fetch_all(module.module, metadata))
    end)
  end

  # ######## #
  # Game API #
  # ######## #

  def get_data(instance_id) do
    Data.Querier.modules()
    |> Enum.filter(fn m -> m.export end)
    |> Enum.reduce(%{}, fn m, acc ->
      Map.put(acc, m.string, Data.Querier.all(m.module, instance_id))
    end)
  end

  # ########## #
  # Public API #
  # ########## #

  def one(module, instance_id, val) do
    one(module, instance_id, :key, val)
  end

  def one(module, instance_id, key, val) do
    data_from_cache(instance_id, module)
    |> Enum.filter(fn item ->
      {:ok, fetched_val} = Map.fetch(item, key)
      fetched_val == val
    end)
    |> List.first()
  end

  def all(module, instance_id) do
    data_from_cache(instance_id, module)
  end

  def all(instance_id) do
    Data.Data.get(instance_id, :data)
  end

  def get_metadata(instance_id) do
    Data.Data.get(instance_id, :metadata)
  end

  defp data_from_cache(instance_id, module) do
    Map.fetch!(Data.Data.get(instance_id, :data), module)
  end
end
