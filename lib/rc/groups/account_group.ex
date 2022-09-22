defmodule RC.Groups.AccountGroup do
  use Ecto.Schema
  alias RC.Accounts.Account
  alias RC.Groups.Group
  import Ecto.Changeset

  @primary_key false
  schema "account_groups" do
    belongs_to(:account, Account, primary_key: true)
    belongs_to(:group, Group, primary_key: true)
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:account_id, :group_id])
    |> validate_required([:account_id, :group_id])
    |> foreign_key_constraint(:account_id)
    |> foreign_key_constraint(:group_id)
    |> unique_constraint(:unique, name: :account_groups_pkey)
  end
end
