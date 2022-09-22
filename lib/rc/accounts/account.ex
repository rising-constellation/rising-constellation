defmodule RC.Accounts.Account do
  use Ecto.Schema

  import Ecto.Changeset
  import Filtrex.Type.Config

  alias Argon2

  @email_format ~r/^.+@.{3,}$/

  def jason(), do: [only: [:id, :email, :name, :role, :status, :lang, :settings, :money]]

  schema "accounts" do
    field(:email, :string)
    field(:hashed_password, :string)
    field(:name, :string)
    field(:role, AccountRole)
    field(:status, AccountStatus)
    field(:mautic_contact_id, :integer)
    field(:steam_id, :decimal)
    field(:password, :string, virtual: true)
    field(:lang, :string)
    field(:settings, :map)
    field(:money, :integer, default: 0)
    field(:is_free, :boolean, default: true)

    has_many(:profiles, RC.Accounts.Profile)
    has_many(:logs, RC.Logs.Log, on_delete: :delete_all)
    has_many(:posts, RC.Blog.Post, on_delete: :delete_all)
    has_many(:account_tokens, RC.Accounts.AccountToken, on_delete: :delete_all)
    has_many(:money_transactions, RC.Accounts.MoneyTransaction, on_delete: :delete_all)

    many_to_many(:groups, RC.Groups.Group, join_through: "account_groups", on_delete: :delete_all)

    timestamps(type: :utc_datetime_usec)
  end

  def filter_options do
    defconfig do
      text(:role)
      text(:status)
    end
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:email, :password, :name, :role, :status, :mautic_contact_id, :steam_id, :lang, :settings])
    |> validate_required([:email, :name, :role, :status])
    |> validate_email(:email)
    |> validate_length(:name, max: 50)
    |> validate_length(:lang, max: 2)
    |> unique_constraint(:email, name: :accounts_lower_email_index)
    |> unique_constraint(:email)
    |> put_hashed_password()
  end

  @doc false
  def changeset_password(account, attrs) do
    account
    |> cast(attrs, [:email, :password, :name, :role, :status, :lang, :settings])
    |> validate_required([:email, :password, :name, :role, :status])
    |> validate_email(:email)
    |> validate_length(:name, max: 50)
    |> unique_constraint(:email, name: :accounts_lower_email_index)
    |> unique_constraint(:email)
    |> put_hashed_password()
  end

  @doc false
  def changeset_steam(account, attrs) do
    account
    |> cast(attrs, [:email, :password, :name, :role, :status, :mautic_contact_id, :steam_id])
    |> validate_required([:email, :name, :role, :status, :steam_id])
    |> validate_email(:email)
    |> unique_constraint(:email, name: :accounts_lower_email_index)
    |> unique_constraint(:email)
    |> unique_constraint(:steam_id)
  end

  @doc false
  def changeset_is_free(account, is_free) do
    account
    |> cast(%{is_free: is_free}, [:is_free])
    |> validate_required([:is_free])
  end

  def validate_email(changeset, field) do
    changeset
    |> update_change(field, &String.trim/1)
    |> validate_format(field, @email_format)
    |> validate_domain(field)
    |> validate_length(field, max: 255)
  end

  defp put_hashed_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :hashed_password, Argon2.hash_pwd_salt(password))
        |> put_change(:password, nil)

      _ ->
        changeset
    end
  end

  defp validate_domain(changeset, field) do
    validate_change(changeset, field, fn _, email ->
      case EmailGuard.check(email) do
        :ok -> []
        {:error, _} -> [email: "provider is banned"]
      end
    end)
  end

  def role_name(:admin), do: "Administrateur"
  def role_name(:user), do: "Utilisateur"
  def role_name(_), do: ""

  def role_color(:admin), do: "is-blue-1"
  def role_color(:user), do: "is-grey"
  def role_color(_), do: ""

  def status_name(:registered), do: "Non-validé"
  def status_name(:active), do: "Actif"
  def status_name(:inactive), do: "Inactif"
  def status_name(:deleted), do: "Supprimé"
  def status_name(:banned), do: "Banni"
  def status_name(_), do: ""

  def status_color(:registered), do: "is-grey"
  def status_color(:active), do: "is-green-1"
  def status_color(:inactive), do: "is-blue-1"
  def status_color(:deleted), do: "is-red-1"
  def status_color(:banned), do: "is-red-2"
  def status_color(_), do: ""
end
