defmodule RC.RankingsTest do
  use ExUnit.Case, async: true

  alias RC.Rankings

  @data_1 [
    %{
      id: 1,
      instance_id: 999,
      faction_ref: "A",
      final_rank: 1,
      registrations: [
        %{profile: %{id: 1, name: "p01", elo: 1000}},
        %{profile: %{id: 2, name: "p02", elo: 1000}},
        %{profile: %{id: 3, name: "p03", elo: 1150}}
      ]
    },
    %{
      id: 2,
      instance_id: 999,
      faction_ref: "B",
      final_rank: 3,
      registrations: [
        %{profile: %{id: 4, name: "p04", elo: 1000}},
        %{profile: %{id: 5, name: "p05", elo: 1300}},
        %{profile: %{id: 6, name: "p06", elo: 1150}}
      ]
    },
    %{
      id: 3,
      instance_id: 999,
      faction_ref: "C",
      final_rank: 2,
      registrations: [
        %{profile: %{id: 7, name: "p07", elo: 1500}},
        %{profile: %{id: 8, name: "p08", elo: 1500}}
      ]
    }
  ]

  describe "ranking" do
    test "mean_elo/1 computes the means" do
      means = Rankings.mean_elo(@data_1) |> Enum.map(& &1.mean_elo)
      assert means == [1050.0, 1150.0, 1500.0]
    end

    test "expected_outcomes/1" do
      outcomes =
        @data_1
        |> Rankings.mean_elo()
        |> Rankings.expected_outcomes()
        |> Enum.reduce(%{}, fn faction, acc ->
          Map.merge(acc, faction.outcomes)
        end)

      assert outcomes["1 vs 2"].first_wins_pt == 21
      assert outcomes["1 vs 3"].first_wins_pt == 31

      assert outcomes["1 vs 2"].second_loses_pt == -19
      assert outcomes["3 vs 2"].second_loses_pt == -4

      assert outcomes["1 vs 3"].second_loses_pt == -28
      assert outcomes["3 vs 2"].first_wins_pt == 4
    end

    test "expected_outcomes/1 's results are commutative" do
      outcomes =
        @data_1
        |> Rankings.mean_elo()
        |> Rankings.expected_outcomes()
        |> Enum.reduce(%{}, fn faction, acc ->
          Map.merge(acc, faction.outcomes)
        end)

      assert outcomes["1 vs 2"].first_wins_pt ==
               outcomes["2 vs 1"].second_wins_pt

      assert outcomes["1 vs 2"].first_loses_pt ==
               outcomes["2 vs 1"].second_loses_pt

      assert outcomes["1 vs 3"].first_wins_pt ==
               outcomes["3 vs 1"].second_wins_pt

      assert outcomes["1 vs 3"].first_loses_pt ==
               outcomes["3 vs 1"].second_loses_pt

      assert outcomes["3 vs 2"].first_wins_pt ==
               outcomes["2 vs 3"].second_wins_pt

      assert outcomes["3 vs 2"].first_loses_pt ==
               outcomes["2 vs 3"].second_loses_pt
    end

    test "change_by_faction/1" do
      changes =
        @data_1
        |> Rankings.mean_elo()
        |> Rankings.expected_outcomes()
        |> Rankings.change_by_faction()
        |> Enum.map(&Map.take(&1, [:id, :elo_diff]))

      assert changes == [%{id: 1, elo_diff: 26.0}, %{id: 2, elo_diff: -11.5}, %{id: 3, elo_diff: -12.0}]
    end
  end

  test "compute_changes/1" do
    changes =
      @data_1
      |> Rankings.mean_elo()
      |> Rankings.expected_outcomes()
      |> Rankings.change_by_faction()
      |> Rankings.compute_changes()
      |> Enum.map(fn {_instance_id, _profile, changes} -> changes end)

    assert changes == [
             26.0,
             26.0,
             26.0,
             -11.5,
             -11.5,
             -11.5,
             -12.0,
             -12.0
           ]
  end
end
