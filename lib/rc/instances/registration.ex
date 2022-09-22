defmodule RandomString do
  use(Puid)
end

defmodule RC.Instances.Registration do
  use Ecto.Schema

  import Ecto.Changeset

  schema "registrations" do
    field(:token, :string)
    field(:state, :string)
    belongs_to(:faction, RC.Instances.Faction)
    belongs_to(:profile, RC.Accounts.Profile)
    has_many(:player_stats, RC.Instances.PlayerStat)
    has_many(:states, RC.Instances.RegistrationState, on_delete: :delete_all)

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(instance, attrs) do
    instance
    |> cast(attrs, [:token, :faction_id, :profile_id, :state])
    |> validate_required([:token, :faction_id, :profile_id, :state])
    |> foreign_key_constraint(:faction, name: "registrations_faction_id_fkey")
    |> foreign_key_constraint(:profile, name: "registrations_profile_id_fkey")
  end

  def generate_token do
    RandomString.generate()
  end
end
