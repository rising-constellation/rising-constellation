defmodule RC.Maintenance.Log do
  use Ecto.Schema

  import Ecto.Changeset

  @version_format ~r/^\d+\.\d+\.\d+$/

  schema "maintenance_log" do
    field(:flag, :boolean)
    field(:min_client_version, :string)
    belongs_to(:account, RC.Accounts.Account)

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  @doc false
  def changeset(log, attrs) do
    log
    |> cast(attrs, [:flag, :account_id, :min_client_version])
    |> validate_required([:flag, :account_id, :min_client_version])
    |> validate_format(:min_client_version, @version_format)
  end
end
