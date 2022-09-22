defmodule RC.Offers do
  import Ecto.Query, warn: false

  alias RC.Repo
  alias RC.Instances.Offer

  def create(attrs) do
    create(attrs, [], [])
  end

  def create_for_allowed_players(attrs, players) do
    players =
      Ecto.Query.from(p in RC.Accounts.Profile, where: p.id in ^players)
      |> Repo.all()

    create(attrs, players, [])
  end

  def create_for_allowed_factions(attrs, factions) do
    factions =
      Ecto.Query.from(f in RC.Instances.Faction, where: f.id in ^factions)
      |> Repo.all()

    create(attrs, [], factions)
  end

  defp create(attrs, players, factions) do
    is_public = length(players) == 0 and length(factions) == 0

    attrs =
      attrs
      |> Map.put(:status, "active")
      |> Map.put(:is_public, is_public)

    %Offer{}
    |> Offer.changeset(attrs, players, factions)
    |> Repo.insert()
  end

  def update_offer_status(offer, status) do
    offer
    |> Offer.changeset_status(status)
    |> Repo.update()
  end

  def get_offer(id), do: Repo.get(Offer, id)
  def get_offer!(id), do: Repo.get!(Offer, id)

  def get_offers(iid, pid, fid) do
    result =
      Ecto.Adapters.SQL.query!(
        Repo,
        "WITH req AS (
          SELECT o.*
          FROM offers_profiles AS p
          JOIN offers AS o
          ON p.offer_id = o.id
          WHERE p.profile_id = $2

          UNION

          SELECT o.*
          FROM offers_factions AS f
          JOIN offers AS o
          ON f.offer_id = o.id
          WHERE f.faction_id = $3

          UNION

          SELECT o.*
          FROM offers AS o
          WHERE o.is_public = TRUE
        )
        SELECT req.*
        FROM req 
        WHERE req.instance_id = $1
          AND req.profile_id != $2
          AND req.status = $4
        ORDER BY inserted_at DESC",
        [iid, pid, fid, "active"]
      )

    Enum.map(result.rows, &Repo.load(Offer, {result.columns, &1}))
  end

  def get_own_offers(iid, pid) do
    from(o in Offer,
      where: o.instance_id == ^iid and o.profile_id == ^pid and o.status == ^"active",
      order_by: [desc: :inserted_at]
    )
    |> RC.Repo.all()
  end

  def get_sold_offers(iid, pid) do
    from(o in Offer,
      where: o.instance_id == ^iid and o.profile_id == ^pid and o.status == ^"sold",
      order_by: [desc: :inserted_at]
    )
    |> RC.Repo.all()
  end
end
