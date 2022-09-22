defmodule RC.Accounts.Profile do
  use Ecto.Schema

  import Ecto.Changeset
  import Filtrex.Type.Config

  schema "profiles" do
    field(:avatar, :string)
    field(:name, :string)
    field(:full_name, :string)
    field(:description, :string)
    field(:long_description, :string)
    field(:age, :integer)
    field(:elo, :float, default: 1200.0)
    belongs_to(:account, RC.Accounts.Account)
    has_many(:registrations, RC.Instances.Registration)

    timestamps(type: :utc_datetime_usec)
  end

  def filter_options do
    defconfig do
      number(:account_id)
      number(:elo)
    end
  end

  @doc false
  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [:name, :avatar, :account_id, :full_name, :description, :long_description, :age, :elo])
    |> validate_required([:name, :avatar, :account_id])
    |> validate_length(:name, max: 30)
    |> validate_length(:full_name, max: 120)
    |> validate_length(:description, max: 120)
    |> validate_length(:long_description, max: 1200)
    |> validate_number(:age, greater_than_or_equal_to: 10, less_than_or_equal_to: 140)
    |> unique_constraint(:name)
  end
end
