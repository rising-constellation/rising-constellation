defmodule RC.Instances.PlayerReport do
  use Ecto.Schema

  import Ecto.Changeset

  def jason(), do: [only: [:id, :type, :is_archived, :is_starred, :metadata, :report, :inserted_at]]

  schema "player_report" do
    field(:type, :string)
    field(:is_archived, :boolean)
    field(:is_starred, :boolean)
    field(:is_hidden, :boolean)
    field(:metadata, :string)
    field(:report, :string)
    belongs_to(:registration, RC.Instances.Registration)

    timestamps(updated_at: false, type: :utc_datetime_usec)
  end

  @doc false
  def changeset(instance, attrs) do
    instance
    |> cast(attrs, [
      :type,
      :is_archived,
      :is_starred,
      :is_hidden,
      :metadata,
      :report,
      :registration_id
    ])
    |> validate_required([:type, :metadata, :report, :registration_id])
    |> foreign_key_constraint(:registration_id)
  end
end
