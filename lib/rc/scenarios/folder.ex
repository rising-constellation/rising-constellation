defmodule RC.Scenarios.Folder do
  use Ecto.Schema
  import Ecto.Changeset

  @reserved_names Keyword.values(Application.compile_env(:rc, RC.Scenarios.Folder))

  schema "folders" do
    field(:name, :string)
    field(:description, :string)
    belongs_to(:account, RC.Accounts.Account)

    many_to_many(:scenarios, RC.Scenarios.Scenario,
      join_through: "scenarios_folders",
      on_delete: :delete_all,
      on_replace: :delete
    )

    timestamps()
  end

  @doc false
  def changeset(folder, attrs) do
    folder
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
    |> validate_length_folder()
  end

  def changeset_not_reserved(folder, attrs) do
    folder
    |> cast(attrs, [:name, :description, :account_id])
    |> validate_required([:name, :description, :account_id])
    |> validate_exclusion(:name, @reserved_names)
    |> validate_length_folder()
  end

  def changeset_reserved(folder, attrs) do
    folder
    |> cast(attrs, [:name, :description, :account_id])
    |> validate_required([:name, :description, :account_id])
    |> validate_inclusion(:name, @reserved_names)
    |> validate_length_folder()
  end

  defp validate_length_folder(changeset) do
    changeset
    |> validate_length(:name, min: 3, max: 30)
    |> validate_length(:description, max: 1000)
  end
end
