defmodule RC.Instances.Offer do
  use Ecto.Schema

  import Ecto.Changeset

  def jason(), do: [only: [:id, :type, :status, :data, :value, :price, :profile_id, :inserted_at]]

  schema "offers" do
    field(:type, :string)
    field(:status, :string)
    field(:data, :string)
    field(:internal, :binary)
    field(:value, :integer)
    field(:price, :integer)
    field(:is_public, :boolean)

    belongs_to(:profile, RC.Accounts.Profile)
    belongs_to(:instance, RC.Instances.Instance)
    many_to_many(:allowed_players, RC.Accounts.Profile, join_through: "offers_profiles")
    many_to_many(:allowed_factions, RC.Instances.Faction, join_through: "offers_factions")

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(offer, attrs, players, factions) do
    offer
    |> cast(attrs, [:type, :status, :data, :internal, :value, :price, :is_public, :profile_id, :instance_id])
    |> validate_required([:type, :status, :data, :value, :price, :is_public, :profile_id, :instance_id])
    |> foreign_key_constraint(:profile_id)
    |> foreign_key_constraint(:instance_id)
    |> put_assoc(:allowed_players, players)
    |> put_assoc(:allowed_factions, factions)
  end

  @doc false
  def changeset_status(offer, status) do
    offer
    |> cast(%{status: status}, [:status])
    |> validate_required([:status])
  end
end
