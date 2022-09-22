defmodule RC.Uploader.ImageFile do
  @moduledoc """
    The definition module for image files.

    To get the URLs of the different versions of the image:
    - original: `RC.Uploader.ImageFile.url({filename, %{account_id: id}}, :original)`
    - medium: `RC.Uploader.ImageFile.url({filename, %{account_id: id}}, :medium)`
    - thumbnail: `RC.Uploader.ImageFile.url({filename, %{account_id: id}}, :thumb)`

    The filename should be the same as when it was uploaded.
  """
  use Waffle.Definition

  use Waffle.Ecto.Definition

  @versions ~w(original medium thumb)a

  def acl(:original, _), do: :public_read
  def acl(:medium, _), do: :public_read
  def acl(:thumb, _), do: :public_read

  def transform(:original, _) do
    :noaction
  end

  def transform(:thumb, _) do
    {:convert, "-resize x400"}
  end

  def transform(:medium, _) do
    {:convert, "-resize x800"}
  end

  # Whitelist file extensions:
  def validate({file, _}) do
    [valid_image_extensions: valid_image_extensions, max_image_size: max_image_size] =
      Application.get_env(:rc, RC.Uploader)

    Enum.member?(valid_image_extensions, Path.extname(file.file_name)) and
      File.stat!(file.path).size <= max_image_size
  end

  # Override the persisted filenames:
  def filename(version, {file, _}) do
    original_name = Enum.at(String.split(file.file_name, "."), 0)
    original_name <> "_" <> Atom.to_string(version)
  end

  # Override the storage directory:
  def storage_dir(_version, {_file, scope}) do
    storage_dir = Application.get_env(:waffle, :storage_dir)
    image_path = Application.get_env(:rc, RC.Uploader.ImageFile) |> Keyword.get(:path)

    Path.join([
      storage_dir,
      image_path,
      "/accounts/#{scope.account_id}"
    ])
  end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   Application.get_env(:uploads, :url)
  #   |> URI.merge("/accounts/#{scope.account_id}/images")
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
