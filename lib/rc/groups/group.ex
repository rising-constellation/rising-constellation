defmodule RC.Groups.Group do
  use Ecto.Schema
  alias RC.Accounts.Account
  alias RC.Instances.Instance
  import Ecto.Changeset

  schema "groups" do
    field(:name, :string)
    many_to_many(:accounts, Account, join_through: "account_groups", on_delete: :delete_all, on_replace: :delete)
    many_to_many(:instances, Instance, join_through: "instance_groups", on_delete: :delete_all, on_replace: :delete)

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name])
    |> cast_assoc(:accounts)
    |> cast_assoc(:instances)
    |> validate_required([:name])
    |> validate_length(:name, max: 120)
    |> validate_exclusion(:name, blocklist())
  end

  def changeset_update(group, objects, type) do
    group
    |> cast(%{}, [:name])
    |> validate_exclusion(:name, blocklist())
    # associate projects to the user
    |> put_assoc(type, objects)
  end

  defp blocklist do
    Application.get_env(:rc, RC.Groups) |> Keyword.get(:reserved_names)
  end
end
