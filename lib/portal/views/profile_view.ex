defmodule Portal.ProfileView do
  use Portal, :view
  alias Portal.ProfileView

  def render("index.json", %{profiles: profiles}) do
    render_many(profiles, ProfileView, "profile.json")
  end

  def render("show.json", %{profile: profile}) do
    render_one(profile, ProfileView, "profile.json")
  end

  def render("profile.json", %{profile: profile}) do
    view = %{
      id: profile.id,
      name: profile.name,
      avatar: profile.avatar,
      full_name: profile.full_name,
      description: profile.description,
      long_description: profile.long_description,
      age: profile.age
    }

    if Ecto.assoc_loaded?(profile.registrations),
      do:
        Map.put(
          view,
          :registrations,
          render_many(profile.registrations, Portal.RegistrationView, "registration.json", as: :registration)
        ),
      else: view
  end
end
