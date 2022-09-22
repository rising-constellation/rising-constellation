defmodule Portal.GroupView do
  use Portal, :view
  alias Portal.GroupView

  def render("index.json", %{groups: groups}) do
    render_many(groups, GroupView, "group.json")
  end

  def render("show.json", %{group: group}) do
    render_one(group, GroupView, "group.json")
  end

  def render("group.json", %{group: group}) do
    view = %{id: group.id, name: group.name}

    view =
      if Ecto.assoc_loaded?(group.accounts),
        do: Map.put(view, :accounts, render_many(group.accounts, Portal.AccountView, "account.json", as: :account)),
        else: view

    if Ecto.assoc_loaded?(group.instances),
      do:
        Map.put(
          view,
          :instances,
          render_many(group.instances, Portal.InstanceView, "instance_partial.json", as: :instance)
        ),
      else: view
  end
end
