defmodule RC.Accounts.MoneyTransaction do
  use Ecto.Schema

  import Ecto.Changeset
  import Filtrex.Type.Config

  schema "money_transactions" do
    field(:amount, :integer)
    field(:money, :integer)
    field(:reason, :string)
    belongs_to(:account, RC.Accounts.Account)

    timestamps(type: :utc_datetime_usec)
  end

  def filter_options do
    defconfig do
      number(:account_id)
    end
  end

  @doc false
  def changeset(money_transaction, attrs) do
    money_transaction
    |> cast(attrs, [:amount, :money, :reason, :account_id])
    |> validate_required([:amount, :money, :reason, :account_id])
  end
end
