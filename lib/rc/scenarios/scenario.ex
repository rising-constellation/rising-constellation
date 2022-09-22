defmodule RC.Scenarios.Scenario do
  use Ecto.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset

  alias RC.Uploader.ThumbnailFile

  schema "scenarios" do
    field(:game_data, :map)
    field(:game_metadata, :map)
    field(:is_map, :boolean)
    field(:is_official, :boolean, default: false)
    field(:thumbnail, ThumbnailFile.Type)
    field(:likes, :integer, virtual: true)
    field(:dislikes, :integer, virtual: true)
    field(:favorites, :integer, virtual: true)

    many_to_many(:folders, RC.Scenarios.Folder,
      join_through: "scenarios_folders",
      on_delete: :delete_all,
      on_replace: :delete
    )

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(scenario, attrs) do
    scenario
    |> cast(attrs, [:game_data, :game_metadata, :is_map, :is_official])
    |> validate_required([:game_data, :game_metadata, :is_map, :is_official])
  end

  @doc false
  def changeset_reuse_thumbnail(scenario, attrs) do
    scenario
    |> cast(attrs, [:game_data, :game_metadata, :is_map, :is_official, :thumbnail])
    |> validate_required([:game_data, :game_metadata, :is_map, :is_official, :thumbnail])
  end

  @doc false
  def changeset_no_thumbnail(scenario, attrs) do
    scenario
    |> cast(attrs, [:game_data, :game_metadata, :is_map, :is_official])
    |> validate_required([:game_data, :game_metadata, :is_map, :is_official])
  end

  def thumbnail_changeset(scenario, attrs) do
    scenario
    |> cast_attachments(attrs, [:thumbnail])
    |> validate_required([:thumbnail])
  end
end
