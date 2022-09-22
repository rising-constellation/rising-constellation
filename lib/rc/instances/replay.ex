defmodule RC.Instances.Replay do
  use Ecto.Schema
  import Ecto.Changeset

  def jason(), do: [only: [:id, :msg, :params, :timestamp, :channel, :profile_id, :duration]]

  schema "replays" do
    field(:msg, :string)
    field(:params, :map)
    field(:timestamp, :utc_datetime_usec)
    field(:channel, :string)
    field(:result, :string)
    field(:duration, :integer)

    belongs_to(:instance, RC.Instances.Instance)
    belongs_to(:profile, RC.Accounts.Profile)
  end

  @doc false
  def changeset(model, attrs) do
    model
    |> cast(attrs, [:msg, :params, :instance_id, :profile_id, :timestamp, :channel, :result, :duration])
    |> foreign_key_constraint(:instance_id)
    |> foreign_key_constraint(:profile_id)
    |> validate_required([:msg, :params, :instance_id, :profile_id, :timestamp, :channel, :duration])
  end
end
