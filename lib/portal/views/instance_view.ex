defmodule Portal.InstanceView do
  use Portal, :view
  alias Portal.InstanceView

  def render("index.json", %{instances: instances}) do
    render_many(instances, InstanceView, "instance_partial.json")
  end

  def render("show.json", %{instance: instance}) do
    render_one(instance, InstanceView, "instance_full.json")
  end

  def render("export_replay.json", %{instance: instance, registrations: registrations, replay: replay}) do
    %{
      instance: render_one(instance, InstanceView, "instance_export.json"),
      registrations: render_many(registrations, Portal.RegistrationView, "registrations_export_fragment.json"),
      replay: replay
    }
  end

  def render("instance_full.json", %{instance: instance}) do
    view = %{
      id: instance.id,
      name: instance.name,
      game_data: instance.game_data,
      game_metadata: instance.game_metadata,
      opening_date: instance.opening_date,
      registration_type: instance.registration_type,
      registration_status: instance.registration_status,
      game_type: instance.game_type,
      start_setting: instance.start_setting,
      public: instance.public,
      description: instance.description,
      state: instance.state,
      node: instance.node,
      account_id: instance.account_id
    }

    view =
      if Ecto.assoc_loaded?(instance.factions),
        do: Map.put(view, :factions, render_many(instance.factions, Portal.FactionView, "faction.json", as: :faction)),
        else: view

    if Ecto.assoc_loaded?(instance.states),
      do:
        Map.put(
          view,
          :states,
          render_many(instance.states, Portal.InstanceStateView, "instance_state.json", as: :state)
        ),
      else: view
  end

  def render("instance_partial.json", %{instance: instance}) do
    view = %{
      id: instance.id,
      name: instance.name,
      game_metadata: instance.game_metadata,
      opening_date: instance.opening_date,
      registration_type: instance.registration_type,
      registration_status: instance.registration_status,
      game_type: instance.game_type,
      start_setting: instance.start_setting,
      public: instance.public,
      description: instance.description,
      state: instance.state,
      node: instance.node,
      account_id: instance.account_id
    }

    view =
      if Ecto.assoc_loaded?(instance.factions),
        do: Map.put(view, :factions, render_many(instance.factions, Portal.FactionView, "faction.json", as: :faction)),
        else: view

    if Ecto.assoc_loaded?(instance.states),
      do:
        Map.put(
          view,
          :states,
          render_many(instance.states, Portal.InstanceStateView, "instance_state.json", as: :state)
        ),
      else: view
  end

  def render("instance_export.json", %{instance: instance}) do
    view = %{
      id: instance.id,
      name: instance.name,
      opening_date: instance.opening_date,
      game_data: instance.game_data,
      description: instance.description
    }

    Map.put(view, :factions, render_many(instance.factions, Portal.FactionView, "faction.json", as: :faction))
  end
end
