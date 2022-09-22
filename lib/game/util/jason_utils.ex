defmodule JasonUtils do
  def encode(val) when is_float(val), do: Float.round(val, 3)

  def encode(%Queue{} = val) do
    val
    |> Queue.to_list()
    |> encode()
  end

  def encode(val) when is_struct(val) do
    fields = fields_to_encode(val)

    val
    |> Map.from_struct()
    |> Map.take(fields)
    |> encode()
  end

  def encode(val) when is_list(val) do
    val
    |> Enum.map(&encode(&1))
  end

  def encode(val) when is_tuple(val) do
    val
    |> Tuple.to_list()
    |> Enum.map(&encode(&1))
  end

  def encode(val) when is_map(val) do
    val
    |> Enum.reduce(%{}, fn {key, val}, acc ->
      Map.put(acc, key, encode(val))
    end)
  end

  def encode(val), do: val

  defp fields_to_encode(struct) do
    opts =
      if function_exported?(struct.__struct__, :jason, 0) do
        struct.__struct__.jason()
      else
        []
      end

    cond do
      only = Keyword.get(opts, :only) ->
        only

      except = Keyword.get(opts, :except) ->
        Map.keys(struct) -- [:__struct__ | except]

      true ->
        Map.keys(struct) -- [:__struct__]
    end
  end
end

# if you ended up here because of:
# "(Protocol.UndefinedError) protocol Jason.Encoder not implemented for %Your.New.Module{}
# Jason.Encoder protocol must always be explicitly implemented.",
# add your module to the list below
defimpl Jason.Encoder,
  for: [
    Core.Bonus,
    Core.CooldownValue,
    Core.DynamicValue,
    Core.Value,
    Core.ValuePart,
    Core.VisibilityValue,
    Data.Game.BonusPipelineIn,
    Data.Game.BonusPipelineOut,
    Data.Game.Building,
    Data.Game.Calendar,
    Data.Game.Character,
    Data.Game.CharacterIllustration,
    Data.Game.CharacterRank,
    Data.Game.Constant,
    Data.Game.Culture,
    Data.Game.Doctrine,
    Data.Game.Faction,
    Data.Game.Patent,
    Data.Game.Ship,
    Data.Game.Speed,
    Data.Game.StellarBody,
    Data.Game.StellarSystem,
    Data.Game.PopulationStatus,
    Data.Game.PopulationClass,
    Instance.Character.Action,
    Instance.Character.ActionQueue,
    Instance.Character.Army,
    Instance.Character.Character,
    Instance.Character.Player,
    Instance.Character.Ship,
    Instance.Character.ShipUnit,
    Instance.Character.Speaker,
    Instance.Character.Spy,
    Instance.Character.Tile,
    Instance.CharacterMarket.CharacterMarket,
    Instance.Faction.Character,
    Instance.Faction.ChatMessage,
    Instance.Faction.Faction,
    Instance.Faction.Player,
    Instance.Faction.StellarSystem,
    Instance.Galaxy.Galaxy,
    Instance.Galaxy.Sector,
    Instance.Galaxy.StellarSystem,
    Instance.Player.Character,
    Instance.Player.Player,
    Instance.Player.PublicPlayer,
    Instance.Player.StellarSystem,
    Instance.StellarSystem.Character,
    Instance.StellarSystem.Player,
    Instance.StellarSystem.ProductionItem,
    Instance.StellarSystem.ProductionQueue,
    Instance.StellarSystem.Siege,
    Instance.StellarSystem.StellarBody,
    Instance.StellarSystem.StellarSystem,
    Instance.StellarSystem.Tile,
    Instance.Time.Time,
    Instance.Victory.Faction,
    Instance.Victory.Sector,
    Instance.Victory.Victory,
    Notification.Notification,
    Notification.Character,
    Notification.System,
    Queue,
    RC.Accounts.Account,
    RC.Instances.Offer,
    RC.Instances.PlayerReport,
    RC.Instances.PlayerEvent,
    RC.Instances.Replay,
    Spatial.Disk,
    Spatial.Position
  ] do
  def encode(struct, opts) do
    JasonUtils.encode(struct)
    |> Jason.Encode.value(opts)
  end
end
