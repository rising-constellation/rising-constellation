defmodule RC.Instances.Instance do
  use Ecto.Schema

  import Ecto.Changeset
  import Filtrex.Type.Config

  schema "instances" do
    field(:game_data, :map)
    field(:game_metadata, :map)
    field(:name, :string)
    field(:description, :string)
    field(:opening_date, :utc_datetime_usec)
    field(:registration_type, InstanceRegistrationType)
    field(:registration_status, InstanceRegistrationStatus)
    field(:start_setting, ScenarioStartSettings)
    field(:game_type, InstanceGameType)
    field(:public, :boolean)
    field(:state, :string)
    field(:node, :string, virtual: true)
    belongs_to(:account, RC.Accounts.Account)
    has_one(:victory, RC.Instances.Victory)
    has_many(:factions, RC.Instances.Faction, on_delete: :delete_all)
    has_many(:player_stats, RC.Instances.PlayerStat)
    has_many(:snapshots, RC.Instances.InstanceSnapshot)
    has_many(:states, RC.Instances.InstanceState, on_delete: :delete_all)
    many_to_many(:groups, RC.Groups.Group, join_through: "instance_groups", on_delete: :delete_all)

    timestamps(type: :utc_datetime_usec)
  end

  def filter_options do
    # additional filters can be found in RC.Instances.put_instance_json_filters/2
    defconfig do
      number(:id)
      date(:opening_date, format: "{0M}-{0D}-{YYYY}")
      boolean(:public)
      text(:name)
      text(:state)
    end
  end

  @doc false
  def changeset(instance, attrs) do
    instance
    |> cast(attrs, [
      :name,
      :game_data,
      :game_metadata,
      :opening_date,
      :registration_type,
      :registration_status,
      :start_setting,
      :game_type,
      :description,
      :public,
      :account_id,
      :state
    ])
    |> validate_required([
      :name,
      :game_data,
      :game_metadata,
      :opening_date,
      :registration_type,
      :registration_status,
      :start_setting,
      :game_type,
      :description,
      :public,
      :account_id
    ])
    |> validate_length(:name, max: 120)
    |> validate_length(:description, max: 5_000)
  end

  def state_name("created"), do: "Créée"
  def state_name("open"), do: "Ouverte"
  def state_name("running"), do: "En marche"
  def state_name("not_running"), do: "Arrêté"
  def state_name("maintenance"), do: "En maintenance"
  def state_name("paused"), do: "En pause"
  def state_name("ended"), do: "Terminée"
  def state_name(_), do: ""

  def state_color("created"), do: "is-grey"
  def state_color("open"), do: "is-grey"
  def state_color("running"), do: "is-green-1"
  def state_color("not_running"), do: "is-red-2"
  def state_color("maintenance"), do: "is-red-1"
  def state_color("paused"), do: "is-blue-1"
  def state_color("ended"), do: "is-grey"
  def state_color(_), do: ""
end
