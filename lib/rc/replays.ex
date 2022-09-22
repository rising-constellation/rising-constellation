defmodule RC.Replays do
  @moduledoc """
  The Replays context.
  """

  import Ecto.Query, warn: false
  alias RC.Repo
  alias RC.Instances.Replay

  require Logger

  def create_replay(attrs \\ %{}) do
    %Replay{}
    |> Replay.changeset(attrs)
    |> Repo.insert()
  end

  def admin_filter(instance_id) do
    from(r in Replay,
      join: profile in assoc(r, :profile),
      where: r.instance_id == ^instance_id,
      preload: [profile: profile],
      order_by: [asc: :timestamp]
    )
    |> Repo.all()
    |> filter()
  end

  def admin_filter(instance_id, profile_id) do
    from(r in Replay,
      join: profile in assoc(r, :profile),
      where: r.instance_id == ^instance_id and profile.id == ^profile_id,
      preload: [profile: profile],
      order_by: [asc: :timestamp]
    )
    |> Repo.all()
    |> filter()
  end

  defp filter(replay) do
    msg_to_filter_out = [
      "get_reports",
      "get_stats"
    ]

    replay
    |> Stream.filter(fn %RC.Instances.Replay{msg: msg, result: result} ->
      (String.starts_with?(result, "{:ok,") or
         result == ":ok") and
        not Enum.member?(msg_to_filter_out, msg)
    end)
    |> Enum.to_list()
  end
end
