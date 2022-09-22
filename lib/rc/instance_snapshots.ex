defmodule RC.InstanceSnapshots do
  import Ecto.Query, warn: false

  alias RC.Repo
  alias RC.Instances.InstanceSnapshot

  def list(iid) do
    from(inst_snapshot in InstanceSnapshot,
      where: inst_snapshot.instance_id == ^iid
    )
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def last(iid) do
    from(inst_snapshot in InstanceSnapshot,
      where: inst_snapshot.instance_id == ^iid
    )
    |> order_by(desc: :inserted_at)
    |> limit(1)
    |> Repo.one()
  end

  @doc """
  Gets a single instance_snapshot.

  ## Examples

      iex> get(123)
      %InstanceSnapshot{}

      iex> get(456)
      nil

  """
  def get(id), do: Repo.get(InstanceSnapshot, id)

  @doc """
  Creates an instance_snapshot.

  ## Examples

      iex> insert(%{field: value})
      {:ok, %InstanceSnapshot{}}

      iex> insert(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def insert(attrs \\ %{}) do
    %InstanceSnapshot{}
    |> InstanceSnapshot.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes an instance_snapshot.

  ## Examples

      iex> delete(instance_snapshot)
      {:ok, %InstanceSnapshot{}}

      iex> delete(instance_snapshot)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%InstanceSnapshot{} = instance_snapshot) do
    Repo.delete(instance_snapshot)
  end
end
