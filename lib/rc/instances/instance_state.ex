defmodule RC.Instances.InstanceState do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_states ["created", "open", "running", "paused", "not_running", "ended", "maintenance"]

  schema "instance_states" do
    field(:state, :string)
    belongs_to(:account, RC.Accounts.Account)
    belongs_to(:instance, RC.Instances.Instance)

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  @doc false
  def changeset(instance_state, attrs) do
    instance_state
    |> cast(attrs, [:state, :instance_id, :account_id])
    |> validate_required([:state, :instance_id, :account_id])
    |> validate_inclusion(:state, @valid_states)
  end
end
