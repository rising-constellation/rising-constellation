defmodule RC.Logs.Log do
  use Ecto.Schema

  import Ecto.Changeset

  schema "logs" do
    field(:action, LogAction)
    belongs_to(:account, RC.Accounts.Account)

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(log, attrs) do
    log
    |> cast(attrs, [:action, :account_id])
    |> validate_required([:action, :account_id])
  end

  def action_name(:create_account), do: "Création de compte"
  def action_name(:login), do: "Connexion"
  def action_name(:update_restricted), do: "Mise à jour du profil (restreint)"
  def action_name(:update), do: "Mise à jour du profil"
  def action_name(:account_validation), do: "Validation de compte"
  def action_name(:reset_password), do: "Réinitialisation du mot de passe"
  def action_name(_), do: "Action inconnue"
end
