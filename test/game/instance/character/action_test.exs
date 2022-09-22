defmodule Character.ActionTest do
  use ExUnit.Case, async: true
  alias Instance.Character.Action

  doctest Action, import: true

  test "compute_progress/2" do
    progress =
      %Action{
        data: %{},
        remaining_time: 1000,
        started_at: nil,
        total_time: 1000,
        cumulated_pauses: 0,
        type: :jump
      }
      |> Action.compute_progress(120)
      |> Float.round(2)

    assert progress == 0.0

    progress =
      %Action{
        data: %{},
        remaining_time: 1000,
        started_at: Instance.Time.Time.now(),
        total_time: 1000,
        cumulated_pauses: 0,
        type: :jump
      }
      |> Action.compute_progress(120)
      |> Float.round(2)

    assert progress == 0.0

    progress =
      %Action{
        data: %{},
        remaining_time: 200,
        started_at: Instance.Time.Time.now(),
        total_time: 1000,
        cumulated_pauses: 0,
        type: :jump
      }
      |> Action.compute_progress(120)
      |> Float.round(2)

    assert progress == 0.0

    progress =
      %Action{
        data: %{},
        remaining_time: 500,
        started_at: Instance.Time.Time.now(),
        total_time: 1000,
        cumulated_pauses: 0,
        type: :jump
      }
      |> Action.compute_progress(120)
      |> Float.round(2)

    assert progress == 0.0

    progress =
      %Action{
        data: %{},
        remaining_time: 880,
        started_at: Instance.Time.Time.now(),
        total_time: 1000,
        cumulated_pauses: 0,
        type: :jump
      }
      |> Action.compute_progress(120)
      |> Float.round(2)

    assert progress == 0.0

    progress =
      %Action{
        data: %{},
        remaining_time: 0,
        started_at: Instance.Time.Time.now(),
        total_time: 1000,
        cumulated_pauses: 0,
        type: :jump
      }
      |> Action.compute_progress(120)
      |> Float.round(2)

    assert progress == 1.0

    progress =
      %Action{
        data: %{},
        remaining_time: 500,
        started_at: Instance.Time.Time.now() - 60_000,
        total_time: 1000,
        cumulated_pauses: 0,
        type: :jump
      }
      |> Action.compute_progress(120)
      |> Float.round(2)

    assert progress == 0.04

    progress =
      %Action{
        data: %{},
        remaining_time: 500,
        started_at: Instance.Time.Time.now() - 60_000,
        total_time: 1000,
        cumulated_pauses: 0,
        type: :jump
      }
      |> Action.compute_progress(12)
      |> Float.round(3)

    assert progress == 0.004
  end
end
