defmodule Portal.UploadView do
  use Portal, :view
  alias Portal.UploadView

  def render("index.json", %{uploads: uploads}) do
    render_many(uploads, UploadView, "upload.json")
  end

  def render("show.json", %{upload: upload}) do
    render_one(upload, UploadView, "upload.json")
  end

  def render("upload.json", %{upload: upload}) do
    %{
      id: upload.id,
      content_type: upload.content_type,
      file: upload.file,
      medium_file: upload.medium_file,
      thumb_file: upload.thumb_file,
      name: upload.name,
      account_id: upload.account.id,
      account_name: upload.account.name,
      account_role: upload.account.role
    }
  end
end
