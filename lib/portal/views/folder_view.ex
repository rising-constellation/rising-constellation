defmodule Portal.FolderView do
  use Portal, :view
  alias Portal.FolderView

  def render("index.json", %{folders: folders}) do
    render_many(folders, FolderView, "folder.json")
  end

  def render("show.json", %{folder: folder}) do
    render_one(folder, FolderView, "folder.json")
  end

  def render("folder.json", %{folder: folder}) do
    %{id: folder.id, name: folder.name, account_id: folder.account_id}
  end
end
