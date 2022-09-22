defmodule Portal.UploadController do
  @moduledoc """
  The Uploads controller.

  Files uploaded have the URI:
  `https://waffle-uploads.s3.fr-par.scw.cloud/storage/files/accounts/{id}/{filename}`

  Image uploaded have the URI:
  `https://waffle-uploads.s3.fr-par.scw.cloud/storage/images/accounts/{id}/{image_filename}`

  The URI of the file uploaded is the URI of Waffle `asset_host` joined with the value computed in `RC.Uploader.StandardFile` and `RC.Uploader.ImageFile`.


  API:

  Create an Upload, if the file is an image 3 images are stored with the following shapes: original, 800x800 and 400x400:
      POST /uploads, body: %{name: name, file: %Plug.Upload object}
  List all Uploads (filters available: name, content_type, account_id):
      GET /uploads, body: filter_params
  Delete an Upload:
      DELETE /uploads
  """
  use Portal, :controller

  alias RC.Uploader
  alias RC.Uploader.Upload

  require Logger

  action_fallback(Portal.FallbackController)

  def index(conn, params) do
    case Uploader.list_uploads(params) do
      {:ok, uploads} ->
        conn
        |> Scrivener.Headers.paginate(uploads)
        |> render("index.json", uploads: uploads)

      {:error, reason} ->
        Logger.info("#{inspect(reason)}")

        conn
        |> put_status(500)
        |> json(%{message: :general_error})
    end
  end

  def upload(conn, %{"name" => name, "file" => plug_upload}) do
    aid = conn.private.guardian_default_resource.id

    {result, message} =
      case get_content_type(plug_upload) do
        "image" ->
          {Uploader.create_image_upload(%{
             name: name,
             file: plug_upload,
             account_id: aid,
             content_type: "image"
           }), :image_file_uploaded}

        type ->
          {Uploader.create_standard_upload(%{
             name: name,
             file: plug_upload,
             account_id: aid,
             content_type: type
           }), :standard_file_uploaded}
      end

    case result do
      {:ok, _} ->
        conn
        |> put_status(201)
        |> json(%{message: message})

      error ->
        error
    end
  end

  defp get_content_type(plug_upload) do
    content_type = plug_upload.content_type

    cond do
      String.match?(content_type, ~r/image\/.*/) -> "image"
      String.match?(content_type, ~r/audio\/.*/) -> "audio"
      String.match?(content_type, ~r/font\/.*/) -> "font"
      String.match?(content_type, ~r/video\/.*/) -> "video"
      String.match?(content_type, ~r/application\/zip/) -> "zip"
      String.match?(content_type, ~r/application\/pdf/) -> "pdf"
      true -> content_type
    end
  end

  def delete(conn, %{"upid" => id}) do
    with upload when not is_nil(upload) <- Uploader.get_upload(id),
         {:ok, %Upload{}} <- Uploader.delete_upload(upload) do
      send_resp(conn, :no_content, "")
    else
      nil ->
        conn
        |> put_status(404)
        |> json(%{message: :upload_not_found})

      {:error, reason} ->
        Logger.info("#{inspect(reason)}")

        conn
        |> put_status(500)
        |> json(%{message: :general_error})
    end
  end
end
