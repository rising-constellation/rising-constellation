defmodule RC.Instances.Victory do
  use Ecto.Schema

  import Ecto.Changeset

  schema "victories" do
    # win_on_time, sector_points, …
    field(:victory_type, :string)
    belongs_to(:instance, RC.Instances.Instance)

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  @doc false
  def changeset(log, attrs) do
    log
    |> cast(attrs, [:victory_type, :instance_id])
    |> validate_required([:victory_type, :instance_id])
    |> unique_constraint(:instance_id)
    |> foreign_key_constraint(:instance_id)
  end
end
