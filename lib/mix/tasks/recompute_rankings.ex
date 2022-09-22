defmodule Mix.Tasks.RecomputeRankings do
  @moduledoc """
  Recompute all rankings

  Preview:
  $ mix recompute_rankings

  Write:
  $ mix recompute_rankings write
  """
  use Mix.Task

  alias RC.Accounts.Profile
  alias RC.Rankings

  import Ecto.Query, warn: false

  # to filter out rage quitters or people who join and don't play,
  # we should mark their registrations so that we can directly query them
  # and exclude them from rankings computations incl. mean ELO

  def run(["write"]) do
    Mix.Task.run("app.start")
    Rankings.recompute_rankings()
  end

  def run(_args) do
    Mix.Task.run("app.start")

    Rankings.get_all_victories()
    |> Enum.each(&preview_rankings/1)
  end

  defp preview_rankings(victory) do
    victory
    |> Enum.map(fn faction -> faction.id end)
    |> RC.Rankings.instance_ranking_query()
    |> Enum.map(&Map.from_struct/1)
    |> Rankings.mean_elo()
    |> Rankings.expected_outcomes()
    |> Rankings.change_by_faction()
    |> Rankings.compute_changes()
    # get rid of most of %Profile{} to pretty print
    |> Enum.map(fn {iid, %Profile{name: name, elo: elo}, elo_diff} ->
      IO.puts("#{iid}\t#{elo_diff}\t#{elo} -> #{elo + elo_diff}\t#{name}")
    end)
  end
end
