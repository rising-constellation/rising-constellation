defmodule RC.Uploader.StandardFile do
  @moduledoc """
    The definition module for files.

    To get the URLs of the different versions of the image:
    - original: `RC.Uploader.StandardFile.url({filename, %{account_id: id}}, :original)`

    The filename should be the same as when it was uploaded.
  """
  use Waffle.Definition

  use Waffle.Ecto.Definition

  @versions [:original]

  def acl(:original, _), do: :public_read

  # Whitelist file extensions:
  def validate({file, _}) do
    valid_image_extensions = Application.get_env(:rc, RC.Uploader) |> Keyword.get(:valid_image_extensions)

    not Enum.member?(valid_image_extensions, Path.extname(file.file_name))
  end

  # Override the persisted filenames:
  def filename(version, {file, _scope}) do
    original_name = Enum.at(String.split(file.file_name, "."), 0)
    original_name <> "_" <> Atom.to_string(version)
  end

  def storage_dir(_version, {_file, scope}) do
    storage_dir = Application.get_env(:waffle, :storage_dir)
    standard_path = Application.get_env(:rc, RC.Uploader.StandardFile) |> Keyword.get(:path)

    Path.join([
      storage_dir,
      standard_path,
      "/accounts/#{scope.account_id}"
    ])
  end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   Application.get_env(:uploads, :url)
  #   |> URI.merge("/accounts/#{scope.account_id}/files")
  # end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  # def s3_object_headers(version, {file, scope}) do
  #   [content_type: MIME.from_path(file.file_name)]
  # end
end
