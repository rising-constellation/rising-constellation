defmodule RC.Uploader.ImageUpload do
  use Ecto.Schema
  use Waffle.Ecto.Schema

  import Ecto.Changeset
  import Filtrex.Type.Config

  alias RC.Uploader.ImageFile

  @valid_formats ~w(image)

  schema "uploads" do
    field(:name, :string)
    field(:file, ImageFile.Type)
    field(:thumb_file, ImageFile.Type)
    field(:medium_file, ImageFile.Type)
    field(:content_type, :string)
    belongs_to(:account, RC.Accounts.Account)

    timestamps()
  end

  def filter_options do
    defconfig do
      text(:name)
      text(:content_type)
      number(:account_id)
    end
  end

  def changeset(image, params) do
    image
    |> cast(params, [:name, :account_id, :content_type])
    |> cast_attachments(params, [:file], allow_paths: true)
    |> validate_inclusion(:content_type, @valid_formats)
    |> validate_required([:name, :file, :account_id, :content_type])
  end
end
