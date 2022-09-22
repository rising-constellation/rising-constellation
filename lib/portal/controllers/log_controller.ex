defmodule Portal.LogController do
  use Portal, :controller

  alias RC.Logs

  action_fallback(RCweb.FallbackController)

  def index(conn, _params) do
    logs = Logs.list_logs()
    render(conn, "index.json", logs: logs)
  end

  def index_by_account(conn, %{"aid" => account_id}) do
    logs = Logs.list_logs_by_account(account_id)
    render(conn, "index.json", logs: logs)
  end
end
