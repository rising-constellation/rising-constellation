defmodule SystemAI.BuildingsHelper do
  require Logger

  def get_all_buildings(instance_id) do
    Data.Querier.all(Data.Game.Building, instance_id)
  end

  def get_biome_buildings(biome_key, instance_id) do
    all_buildings = get_all_buildings(instance_id)

    case biome_key do
      :open -> all_buildings |> Enum.filter(fn building -> building.biome == :open end)
      :dome -> all_buildings |> Enum.filter(fn building -> building.biome == :dome end)
      :orbital -> all_buildings |> Enum.filter(fn building -> building.biome == :orbital end)
    end
  end
end
