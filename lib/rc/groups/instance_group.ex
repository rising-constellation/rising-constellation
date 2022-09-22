defmodule RC.Groups.InstanceGroup do
  use Ecto.Schema
  alias RC.Instances.Instance
  alias RC.Groups.Group
  import Ecto.Changeset

  @primary_key false
  schema "instance_groups" do
    belongs_to(:instance, Instance, primary_key: true)
    belongs_to(:group, Group, primary_key: true)
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:instance_id, :group_id])
    |> validate_required([:instance_id, :group_id])
    |> foreign_key_constraint(:instance_id)
    |> foreign_key_constraint(:group_id)
    |> unique_constraint(:unique, name: :instance_groups_pkey)
  end
end
