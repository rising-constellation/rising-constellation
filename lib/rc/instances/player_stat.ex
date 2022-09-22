defmodule RC.Instances.PlayerStat do
  use Ecto.Schema

  import Ecto.Changeset

  schema "player_stats" do
    field(:output_credit, :integer)
    field(:output_technology, :integer)
    field(:output_ideology, :integer)
    field(:stored_credit, :integer)
    field(:total_systems, :integer)
    field(:total_population, :integer)
    field(:points, :integer)
    field(:best_prod, :integer)
    field(:best_credit, :integer)
    field(:best_technology, :integer)
    field(:best_ideology, :integer)
    field(:best_workforce, :integer)
    belongs_to(:instance, RC.Instances.Instance)
    belongs_to(:registration, RC.Instances.Registration)

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(instance, attrs) do
    instance
    |> cast(attrs, [
      :output_credit,
      :output_technology,
      :output_ideology,
      :stored_credit,
      :total_systems,
      :total_population,
      :points,
      :best_prod,
      :best_credit,
      :best_technology,
      :best_ideology,
      :best_workforce,
      :instance_id,
      :registration_id
    ])
    |> validate_required([
      :output_credit,
      :output_technology,
      :output_ideology,
      :stored_credit,
      :total_systems,
      :total_population,
      :points,
      :best_prod,
      :best_credit,
      :best_technology,
      :best_ideology,
      :best_workforce,
      :instance_id,
      :registration_id
    ])
    |> foreign_key_constraint(:instance_id)
    |> foreign_key_constraint(:registration_id)
  end
end
