defmodule RC.Scenarios.Map do
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
      join_keys: [scenario_id: :id, folder_id: :id],
      on_delete: :delete_all,
      on_replace: :delete
    )

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(map, attrs) do
    map
    |> cast(attrs, [:game_data, :game_metadata, :is_map, :is_official])
    |> validate_change(:is_map, fn :is_map, is_map_bool ->
      if is_map_bool,
        do: [],
        else: [is_map: "must be true when manipulating a map"]
    end)
    |> validate_required([:game_data, :game_metadata, :is_map, :is_official])
  end

  @doc false
  def changeset_no_thumbnail(map, attrs) do
    map
    |> cast(attrs, [:game_data, :game_metadata, :is_map, :is_official])
    |> validate_change(:is_map, fn :is_map, is_map_bool ->
      if is_map_bool,
        do: [],
        else: [is_map: "must be true when manipulating a map"]
    end)
    |> validate_required([:game_data, :game_metadata, :is_map, :is_official])
  end

  def thumbnail_changeset(map, attrs) do
    map
    |> cast_attachments(attrs, [:thumbnail])
    |> validate_required([:thumbnail])
  end
end
