defmodule Instance.Player.Character do
  use TypedStruct
  use Util.MakeEnumerable

  def jason(), do: []

  typedstruct enforce: true do
    field(:id, integer())
    field(:status, atom())
    field(:type, atom())
    field(:specialization, atom())
    field(:name, String.t())
    field(:level, integer())
    field(:system, integer() | nil)
    field(:position, integer() | nil)
    field(:owner, %Instance.Character.Player{} | nil)
    field(:on_sold, boolean())
    field(:action_status, atom() | nil)
    field(:actions, %Instance.Character.ActionQueue{} | nil)
    field(:army_maintenance, integer() | nil)
    field(:army_size, %{} | nil)
    field(:is_discovered, boolean() | nil)
  end

  def convert(character) do
    army_maintenance =
      if character.type == :admiral and character.status == :on_board,
        do: character.army.maintenance.value,
        else: nil

    army_size =
      if character.type == :admiral and character.status == :on_board do
        Enum.reduce(character.army.tiles, %{filled: 0, planned: 0}, fn
          %Instance.Character.Tile{ship_status: :planned}, acc -> Map.put(acc, :planned, Map.get(acc, :planned) + 1)
          %Instance.Character.Tile{ship_status: :filled}, acc -> Map.put(acc, :filled, Map.get(acc, :filled) + 1)
          _, acc -> acc
        end)
      else
        nil
      end

    is_discovered =
      if character.type == :spy and character.status == :on_board,
        do: Instance.Character.Spy.discovered?(character.spy.cover.value, character.instance_id),
        else: nil

    # speaker
    # - repo/pas repo

    %Instance.Player.Character{
      id: character.id,
      status: character.status,
      type: character.type,
      specialization: character.specialization,
      name: character.name,
      level: character.level,
      system: character.system,
      position: character.position,
      owner: character.owner,
      on_sold: character.on_sold,
      action_status: character.action_status,
      actions: character.actions,
      army_maintenance: army_maintenance,
      army_size: army_size,
      is_discovered: is_discovered
    }
  end
end
