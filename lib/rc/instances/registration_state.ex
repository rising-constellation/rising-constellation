defmodule RC.Instances.RegistrationState do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_states ["joined", "playing", "resigned", "dead"]

  schema "registration_states" do
    field(:state, :string)
    belongs_to(:registration, RC.Instances.Registration)

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  @doc false
  def changeset(registration_state, attrs) do
    registration_state
    |> cast(attrs, [:state, :registration_id])
    |> validate_required([:state, :registration_id])
    |> foreign_key_constraint(:registration_id)
    |> validate_inclusion(:state, @valid_states)
  end
end
