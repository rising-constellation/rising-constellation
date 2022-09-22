defmodule Portal.FightController do
  use Portal, :controller

  alias Instance.Character.Character
  alias Instance.Character.Player
  alias Instance.Character.Army

  def run(conn, %{
        "attacker" => %{"initial_xp" => attacker_initial_xp, "tiles" => attacker_army},
        "defender" => %{"initial_xp" => defender_initial_xp, "tiles" => defender_army}
      }) do
    instance_id = :fast_prod

    attacker = Character.new(1, :admiral, :common, 1, instance_id)

    attacker = %{
      attacker
      | owner: %Player{
          id: 1,
          name: "Joueur 1",
          faction: :myrmezir,
          faction_id: 1
        },
        status: :on_board,
        action_status: :idle,
        army: Army.new(instance_id)
    }

    {attacker, _index} =
      Enum.reduce(attacker_army, {attacker, 1}, fn tile, {character, index} ->
        if is_nil(tile) do
          {character, index + 1}
        else
          ship_key = String.to_existing_atom(tile)

          {:ok, character} = Character.order_ship(character, {nil, index, ship_key, nil})
          character = Character.put_ship(character, index, attacker_initial_xp)

          {character, index + 1}
        end
      end)

    defender = Character.new(2, :admiral, :common, 1, instance_id)

    defender = %{
      defender
      | owner: %Player{
          id: 2,
          name: "Joueur 2",
          faction: :tetrarchy,
          faction_id: 2
        },
        status: :on_board,
        action_status: :idle,
        army: Army.new(instance_id)
    }

    {defender, _index} =
      Enum.reduce(defender_army, {defender, 1}, fn tile, {character, index} ->
        if is_nil(tile) do
          {character, index + 1}
        else
          ship_key = String.to_existing_atom(tile)

          {:ok, character} = Character.order_ship(character, {nil, index, ship_key, nil})
          character = Character.put_ship(character, index, defender_initial_xp)

          {character, index + 1}
        end
      end)

    {{attackers, defenders}, logs, metadata, _} = Fight.Manager.fight([attacker], [defender])

    attackers = Enum.map(attackers, fn {_, _, character} -> character end)
    defenders = Enum.map(defenders, fn {_, _, character} -> character end)

    conn
    |> put_status(200)
    |> json(%{
      initial: %{
        attackers: [attacker],
        defenders: [defender]
      },
      final: %{
        attackers: attackers,
        defenders: defenders
      },
      logs: logs,
      metadata: metadata
    })
  end
end
