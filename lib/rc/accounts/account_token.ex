defmodule RC.Accounts.AccountToken do
  use Ecto.Schema

  import Ecto.Changeset
  import Filtrex.Type.Config

  schema "account_tokens" do
    field(:value, :string)
    field(:type, TokenType)
    field(:candidate_email, :string)
    belongs_to(:account, RC.Accounts.Account)

    timestamps(type: :utc_datetime_usec)
  end

  def filter_options do
    defconfig do
      number(:account_id)
    end
  end

  @doc false
  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [:value, :account_id, :type])
    |> validate_required([:value, :account_id, :type])
    |> unique_constraint(:value)
  end

  @doc false
  def changeset_email(profile, attrs) do
    profile
    |> cast(attrs, [:value, :account_id, :type, :candidate_email])
    |> validate_required([:value, :account_id, :type, :candidate_email])
    |> validate_length(:candidate_email, max: 120)
    |> unique_constraint(:value)
    |> RC.Accounts.Account.validate_email(:candidate_email)
    |> unique_constraint(:email, name: :accounts_lower_email_index)
    |> unique_constraint(:email)
  end

  def new() do
    length =
      Application.get_env(:rc, RC.Accounts.AccountToken)
      |> Keyword.get(:length, 32)

    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end
end
