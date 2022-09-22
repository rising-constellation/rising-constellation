defmodule RC.Scenarios.ScenarioFolder do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  schema "scenarios_folders" do
    belongs_to(:folder, RC.Scenarios.Folder, primary_key: true)
    belongs_to(:scenario, RC.Scenarios.Scenario, primary_key: true)
  end

  @doc false
  def changeset(scenario, attrs) do
    scenario
    |> cast(attrs, [:folder_id, :scenario_id])
    |> validate_required([:folder_id, :scenario_id])
    |> foreign_key_constraint(:folder_id)
    |> foreign_key_constraint(:scenario_id)
    |> unique_constraint(:unique, name: :scenario_folders_pkey)
  end
end
