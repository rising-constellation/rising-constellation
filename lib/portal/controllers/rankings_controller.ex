defmodule Portal.RankingsController do
  use Portal, :controller

  require Logger

  def standings(conn, _) do
    render(conn, "standings.json", profiles: RC.Rankings.current_standings())
  end
end
