defmodule Portal.RegistrationView do
  use Portal, :view
  alias Portal.RegistrationView

  def render("index.json", %{registrations: registrations}) do
    render_many(registrations, RegistrationView, "registration.json")
  end

  def render("show.json", %{registration: registration}) do
    render_one(registration, RegistrationView, "registration.json")
  end

  def render("registration.json", %{registration: registration}) do
    view = %{
      id: registration.id,
      token: registration.token,
      state: registration.state
    }

    view =
      if Ecto.assoc_loaded?(registration.faction),
        do: Map.put(view, :faction, render_one(registration.faction, Portal.FactionView, "faction.json", as: :faction)),
        else: view

    if Ecto.assoc_loaded?(registration.profile),
      do: Map.put(view, :profile, render_one(registration.profile, Portal.ProfileView, "profile.json", as: :profile)),
      else: view
  end

  def render("registrations_export_fragment.json", %{registration: registration}) do
    %{
      id: registration.id,
      faction_id: registration.faction_id,
      profile_id: registration.profile_id,
      inserted_at: registration.inserted_at
    }
  end
end
