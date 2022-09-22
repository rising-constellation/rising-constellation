defmodule RC.Accounts.Rankings do
  use Ecto.Schema

  import Ecto.Changeset

  schema "rankings" do
    field(:elo_diff, :float)
    belongs_to(:instance, RC.Instances.Instance)
    belongs_to(:profile, RC.Accounts.Profile)

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  @doc false
  def changeset(ranking, attrs) do
    ranking
    |> cast(attrs, [:elo_diff, :instance_id, :profile_id])
    |> validate_required([:elo_diff, :instance_id, :profile_id])
    |> foreign_key_constraint(:instance_id)
    |> foreign_key_constraint(:profile_id)
  end
end
