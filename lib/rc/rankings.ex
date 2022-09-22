defmodule RC.Rankings do
  alias Ecto.Multi
  alias RC.Accounts.Profile
  alias RC.Accounts.Rankings
  alias RC.Instances.{Instance, Victory, Faction}
  alias RC.Repo

  import Ecto.Query, warn: false

  @b 400
  # volatility
  @k 30
  # inflation
  @i 0.1

  def mean_elo(factions) do
    factions
    |> Enum.map(fn faction ->
      elos = Enum.map(faction.registrations, & &1.profile.elo) |> Enum.sum()
      mean_elo = elos / length(faction.registrations)
      Map.put(faction, :mean_elo, mean_elo)
    end)
  end

  def expected_outcomes(factions) do
    factions
    |> Enum.map(fn faction ->
      outcomes =
        factions
        |> Enum.reject(&(&1.id == faction.id))
        |> Enum.reduce(%{}, fn opposing_faction, acc ->
          {is_probable_winner, win_prob, lose_prob} = compute_prob(faction, opposing_faction)

          Map.put(acc, "#{faction.id} vs #{opposing_faction.id}", %{
            is_probable_winner: is_probable_winner,
            win_prob: win_prob,
            lose_prob: lose_prob,
            first_wins_pt: round(@k * lose_prob * (1 + @i)),
            second_wins_pt: round(@k * win_prob * (1 + @i)),
            first_loses_pt: round(-win_prob * @k),
            second_loses_pt: round(-lose_prob * @k)
          })
        end)

      Map.put(faction, :outcomes, outcomes)
    end)
  end

  def change_by_faction(factions) do
    # score changes must not be affected by how many factions were playing
    # so we average the score per # of opposing faction
    divider = length(factions) - 1

    Enum.map(factions, fn faction ->
      opposing_factions = Enum.reject(factions, &(&1.id == faction.id))

      pts =
        opposing_factions
        |> Enum.map(fn opposing_faction ->
          matchup = faction.outcomes["#{faction.id} vs #{opposing_faction.id}"]

          case faction.final_rank < opposing_faction.final_rank do
            true -> matchup.first_wins_pt
            false -> matchup.first_loses_pt
          end
        end)
        |> Enum.sum()

      Map.put(faction, :elo_diff, pts / divider)
    end)
  end

  def compute_changes(factions) do
    factions
    |> Enum.flat_map(fn faction ->
      instance_id = faction.instance_id

      Enum.map(faction.registrations, fn %{profile: profile} ->
        {instance_id, faction.elo_diff, profile}
      end)
    end)
    |> Enum.map(fn {instance_id, elo_diff, profile} ->
      {instance_id, profile, elo_diff}
    end)
  end

  @doc """
  Updates Elos when a game ends
  """
  def update_rankings(game_outcome) do
    game_outcome
    |> Enum.map(fn faction -> faction.id end)
    |> RC.Rankings.instance_ranking_query()
    |> Enum.map(&Map.from_struct/1)
    |> mean_elo()
    |> expected_outcomes()
    |> change_by_faction()
    |> compute_changes()
    |> Enum.reduce(Multi.new(), fn {instance_id, profile, elo_diff}, trx ->
      elo = Map.get(profile, :elo, 0) + elo_diff

      profile_changeset = Profile.changeset(profile, %{elo: elo})

      ranking_changeset =
        Rankings.changeset(%Rankings{}, %{elo_diff: elo_diff, profile_id: profile.id, instance_id: instance_id})

      trx
      |> Multi.update("update_profile_#{profile.id}", profile_changeset)
      |> Multi.insert("record_ranking_profile_#{profile.id}", ranking_changeset)
    end)
    |> Repo.transaction()
  end

  def get_all_victories() do
    Victory
    |> join(:inner, [victory], instance in assoc(victory, :instance))
    |> join(:left, [victory, instance], factions in assoc(instance, :factions))
    |> preload([victory, instance, factions], instance: {instance, factions: factions})
    |> where(fragment("game_data @> ?", ^%{game_mode_type: "ranked"}))
    |> order_by([victory], asc: victory.inserted_at)
    |> Repo.all()
    |> Enum.map(fn %Victory{instance: %Instance{factions: factions}} ->
      Enum.sort_by(factions, & &1.final_rank)
    end)
  end

  @doc """
  Resets and recomputes all rankings, `$ mix recompute_rankings` can be
  adapted and used to preview changes to the rankings computation
  """
  def recompute_rankings() do
    Repo.query("TRUNCATE rankings RESTART IDENTITY", [])
    Repo.update_all(Profile, set: [elo: 1200])

    get_all_victories()
    |> Enum.each(&update_rankings/1)
  end

  @doc """
  From a list of participating factions, get factions/registrations/profiles to compute ranking
  """
  def instance_ranking_query(faction_ids) do
    factions =
      Faction
      |> where([faction], faction.id in ^faction_ids)
      |> join(:inner, [faction], registrations in assoc(faction, :registrations))
      |> join(:left, [faction, registrations], profile in assoc(registrations, :profile))
      |> preload([faction, registrations, profile], registrations: {registrations, profile: profile})
      |> Repo.all()

    # factions that have at least 1 registration
    factions_with_registrations =
      factions
      |> Enum.map(& &1.registrations)
      |> Enum.map(&length(&1))
      |> Enum.filter(&(&1 > 0))

    cond do
      # we don't update rankings when only one faction had players playing: we don't want people
      # to cheat rankings by being N in the same faction playing against no one and winning on time
      length(factions_with_registrations) <= 1 -> []
      # time to filter out casual games
      not RC.Instances.instance_is_ranked(List.first(factions).instance_id) -> []
      true -> factions
    end
  end

  @doc """
  Profiles with recently updated Elo, sorted by Elo desc
  """
  def current_standings() do
    three_months = 60 * 60 * 24 * 30 * 3

    {:ok, time} = DateTime.from_unix(DateTime.to_unix(DateTime.utc_now()) - three_months)

    Profile
    |> join(:left, [profile], r in Rankings, on: r.profile_id == profile.id)
    |> where([profile, ranking], ranking.inserted_at > ^time)
    |> order_by([profile], desc: profile.elo)
    |> group_by([profile, ranking], profile.id)
    |> Repo.all()
  end

  defp compute_prob(faction, opposing_faction) do
    abs_diff = abs(faction.mean_elo - opposing_faction.mean_elo)
    win_prob = Float.round(1 / (1 + :math.pow(10, abs_diff / @b)), 3)
    lose_prob = Float.round(1 - win_prob, 3)

    is_probable_winner = faction.mean_elo > opposing_faction.mean_elo

    if is_probable_winner do
      {is_probable_winner, lose_prob, win_prob}
    else
      {is_probable_winner, win_prob, lose_prob}
    end
  end
end
