defmodule Portal.RankingsView do
  use Portal, :view

  alias Portal.RankingsView

  def render("standings.json", %{profiles: profiles}) do
    render_many(profiles, RankingsView, "ranked_profile.json", as: :profile)
  end

  def render("ranked_profile.json", %{profile: profile}) do
    %{
      id: profile.id,
      name: profile.name,
      avatar: profile.avatar,
      full_name: profile.full_name,
      elo: profile.elo
    }
  end
end
