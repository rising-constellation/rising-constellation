defmodule Portal.LogView do
  use Portal, :view
  alias Portal.LogView

  def render("index.json", %{logs: logs}) do
    render_many(logs, LogView, "log.json")
  end

  def render("show.json", %{log: log}) do
    render_one(log, LogView, "log.json")
  end

  def render("log.json", %{log: log}) do
    %{id: log.id, action: log.action, account_id: log.account.id, email: log.account.email, date: log.inserted_at}
  end
end
