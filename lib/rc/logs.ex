defmodule RC.Logs do
  @moduledoc """
  The Logs context.
  """

  import Ecto.Query, warn: false
  alias RC.Repo

  alias RC.Logs.Log
  alias RC.Accounts.Account

  @doc """
  Returns the list of logs.

  ## Examples

      iex> list_logs()
      [%Log{}, ...]

  """
  def list_logs(params \\ %{}) do
    from(l in Log, order_by: [desc: :inserted_at])
    |> preload(:account)
    |> RC.Repo.paginate(params)
  end

  def list_logs_by_account(account_id) do
    query =
      from(l in Log,
        where: l.account_id == ^account_id,
        join: a in Account,
        on: a.id == ^account_id,
        order_by: [desc: :inserted_at]
      )
      |> preload(:account)

    RC.Repo.paginate(query, %{})
  end

  @doc """
  Gets a single log.

  Raises `Ecto.NoResultsError` if the Log does not exist.

  ## Examples

      iex> get_log!(123)
      %Log{}

      iex> get_log!(456)
      ** (Ecto.NoResultsError)

  """
  def get_log!(id) do
    Repo.get!(Log, id)
    |> Repo.preload(:account)
  end

  @doc """
  Creates a log.

  ## Examples

      iex> create_log(%{field: value})
      {:ok, %Log{}}

      iex> create_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_log(attrs \\ %{}, %Account{} = account) do
    %Log{account_id: account.id}
    |> Log.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a log.

  ## Examples

      iex> update_log(log, %{field: new_value})
      {:ok, %Log{}}

      iex> update_log(log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_log(%Log{} = log, attrs) do
    log
    |> Log.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a log.

  ## Examples

      iex> delete_log(log)
      {:ok, %Log{}}

      iex> delete_log(log)
      {:error, %Ecto.Changeset{}}

  """
  def delete_log(%Log{} = log) do
    Repo.delete(log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking log changes.

  ## Examples

      iex> change_log(log)
      %Ecto.Changeset{source: %Log{}}

  """
  def change_log(%Log{} = log) do
    Log.changeset(log, %{})
  end
end
