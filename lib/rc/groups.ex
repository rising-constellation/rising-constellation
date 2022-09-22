defmodule RC.Groups do
  @moduledoc """
  The Groups context.
  """

  import Ecto.Query, warn: false
  alias RC.Repo

  alias RC.Groups.Group
  alias RC.Groups.AccountGroup
  alias RC.Groups.InstanceGroup
  alias Ecto.Multi

  def blog_author?(account_id) do
    blog_group_name = Application.get_env(:rc, RC.Groups) |> Keyword.get(:blog_group_name)

    Repo.exists?(
      from(g in Group,
        join: a in assoc(g, :accounts),
        where: a.id == ^account_id and g.name == ^blog_group_name
      )
    )
  end

  def instance_access?(account_id, instance_id) do
    Repo.exists?(
      from(g in Group,
        join: a in assoc(g, :accounts),
        where: a.id == ^account_id,
        join: i in assoc(g, :instances),
        where: i.id == ^instance_id
      )
    )
  end

  def instance_in_group?(instance_id) do
    Repo.exists?(
      from(g in Group,
        join: i in assoc(g, :instances),
        where: i.id == ^instance_id
      )
    )
  end

  def remove_account(group, account_id) do
    Repo.delete_all(
      from(ag in AccountGroup,
        where: ag.account_id == ^account_id and ag.group_id == ^group.id
      )
    )
  end

  def remove_instance(group, instance_id) do
    Repo.delete_all(
      from(ag in InstanceGroup,
        where: ag.instance_id == ^instance_id and ag.group_id == ^group.id
      )
    )
  end

  def insert_accounts(group, account_ids) do
    {trx, _} =
      Enum.reduce(account_ids, {Multi.new(), 0}, fn aid, {trx_acc, idx_acc} ->
        account_params = %{group_id: group.id, account_id: aid}

        {trx_acc
         |> Multi.insert("account_groups_#{idx_acc}", AccountGroup.changeset(%AccountGroup{}, account_params)),
         idx_acc + 1}
      end)

    Repo.transaction(trx)
  end

  def insert_instances(group, instance_ids) do
    {trx, _} =
      Enum.reduce(instance_ids, {Multi.new(), 0}, fn iid, {trx_acc, idx_acc} ->
        instance_params = %{group_id: group.id, instance_id: iid}

        {trx_acc
         |> Multi.insert("instance_groups_#{idx_acc}", InstanceGroup.changeset(%InstanceGroup{}, instance_params)),
         idx_acc + 1}
      end)

    Repo.transaction(trx)
  end

  @doc """
  Returns the list of groups.

  ## Examples

      iex> list_groups()
      [%Group{}, ...]

  """
  def list_groups(params \\ %{}) do
    Group
    |> order_by(desc: :id)
    |> preload(:accounts)
    |> preload(:instances)
    |> Repo.paginate(params)
  end

  @doc """
  Gets a single group.

  Raises `Ecto.NoResultsError` if the Group does not exist.

  ## Examples

      iex> get_group(123)
      %Group{}

      iex> get_group(456)
      nil

  """
  def get_group(id) do
    Repo.get(Group, id)
    |> Repo.preload(:accounts)
    |> Repo.preload(:instances)
  end

  @doc """
  Creates a group.

  ## Examples

      iex> create_group(%{field: value})
      {:ok, %Group{}}

      iex> create_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group(attrs \\ %{}) do
    %Group{}
    |> Group.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a group.

  ## Examples

      iex> update_group(group, %{field: new_value})
      {:ok, %Group{}}

      iex> update_group(group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group(%Group{} = group, attrs) do
    group
    |> Group.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a group.

  ## Examples

      iex> delete_group(group)
      {:ok, %Group{}}

      iex> delete_group(group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group(%Group{} = group) do
    Repo.delete(group)
  end
end
