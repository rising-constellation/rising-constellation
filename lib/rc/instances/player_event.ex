defmodule RC.Instances.PlayerEvent do
  use Ecto.Schema

  import Ecto.Changeset

  def jason(), do: [only: [:id, :key, :type, :data, :instance_id, :registration_id, :inserted_at]]

  schema "player_events" do
    field(:key, :string)
    field(:type, :string)
    field(:data, :string)
    belongs_to(:instance, RC.Instances.Instance)
    belongs_to(:registration, RC.Instances.Registration)
    belongs_to(:faction, RC.Instances.Faction)

    timestamps(updated_at: false, type: :utc_datetime)
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:key, :type, :data, :instance_id, :registration_id, :faction_id])
    |> validate_required([:key, :type, :data, :instance_id])
    |> foreign_key_constraint(:instance_id)
    |> foreign_key_constraint(:registration_id)
    |> foreign_key_constraint(:faction_id)
  end
end
