defmodule Portal.FactionView do
  use Portal, :view
  alias Portal.FactionView

  def render("index.json", %{factions: factions}) do
    render_many(factions, FactionView, "faction.json")
  end

  def render("show.json", %{faction: faction}) do
    render_one(faction, FactionView, "faction.json")
  end

  def render("faction.json", %{faction: faction}) do
    view = %{
      id: faction.id,
      faction_ref: faction.faction_ref,
      capacity: faction.capacity,
      registrations_count: faction.registrations_count
    }

    if Ecto.assoc_loaded?(faction.instance),
      do:
        Map.put(
          view,
          :instance,
          render_one(faction.instance, Portal.InstanceView, "instance_partial.json", as: :instance)
        ),
      else: view
  end
end
