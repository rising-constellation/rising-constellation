defmodule RC.Instances.InstanceSnapshot do
  use Ecto.Schema
  import Ecto.Changeset

  schema "instance_snapshots" do
    field(:name, :string)
    field(:size, :integer)

    belongs_to(:instance, RC.Instances.Instance)

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(instance_snapshot, attrs) do
    instance_snapshot
    |> cast(attrs, [:name, :size, :instance_id])
    |> validate_required([:name, :size, :instance_id])
  end
end
