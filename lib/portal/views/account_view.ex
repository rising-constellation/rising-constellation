defmodule Portal.AccountView do
  use Portal, :view
  alias Portal.AccountView

  def render("index.json", %{accounts: accounts}) do
    render_many(accounts, AccountView, "account.json")
  end

  def render("show.json", %{account: account}) do
    render_one(account, AccountView, "account.json")
  end

  def render("account.json", %{account: account}) do
    view = %{
      id: account.id,
      email: account.email,
      name: account.name,
      role: account.role,
      status: account.status,
      settings: Map.merge(account.settings, %{lang: account.lang}),
      money: account.money,
      is_free: account.is_free
    }

    if Ecto.assoc_loaded?(account.profiles),
      do: Map.put(view, :profiles, render_many(account.profiles, Portal.ProfileView, "profile.json", as: :profile)),
      else: view
  end
end
