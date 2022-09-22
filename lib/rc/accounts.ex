defmodule RC.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Argon2
  alias Ecto.Multi
  alias RC.Accounts.Account
  alias RC.Accounts.AccountToken
  alias RC.Accounts.Profile
  alias RC.Accounts.MoneyTransaction
  alias RC.Logs.Log
  alias RC.Repo
  alias RC.Mailer

  def run_signup_transaction(account_params) do
    Multi.new()
    |> signup_transaction(account_params, false)
    |> Repo.transaction()
  end

  def run_signup_transaction(account_params, token_params, mailer) do
    Multi.new()
    |> signup_transaction(account_params, token_params)
    |> Multi.run(:send_email, fn _repo, %{account: account, account_token: account_token} ->
      mailer.(account, account_token, :verification_template)
    end)
    |> Repo.transaction()
  end

  def run_steam_signup_transaction(account_params) do
    account =
      %Account{}
      |> Account.changeset_steam(account_params)
      |> Account.changeset_is_free(false)

    Multi.new()
    |> Multi.insert(:account, account)
    |> Multi.insert(:log, fn %{account: %Account{id: account_id}} ->
      Log.changeset(%Log{}, %{action: :create_account, account_id: account_id})
    end)
    |> Repo.transaction()
  end

  defp signup_transaction(trx, account_params, token_params) do
    account =
      %Account{}
      |> Account.changeset_is_free(false)

    trx =
      trx
      |> Multi.insert(:account, Account.changeset_password(account, account_params))
      |> Multi.insert(:log, fn %{account: %Account{id: account_id}} ->
        Log.changeset(%Log{}, %{action: :create_account, account_id: account_id})
      end)

    if token_params do
      Multi.insert(trx, :account_token, fn %{account: %Account{id: account_id}} ->
        AccountToken.changeset(%AccountToken{account_id: account_id}, token_params)
      end)
    else
      trx
    end
  end

  @doc """
  Run the transactions to update an account for a mail confirmation, password reset or email update.
  More precisely it updates the account, deletes the token and insert the corresponding log.
  If this is an email update the new email is taken in `account_token.candidate_email`.

  `log_action` should be either `email_verification` or `reset_password`
  """
  def run_account_token_update_transactions(account, account_update_params, account_token, log_action) do
    account_update_params =
      if log_action == :update_with_email,
        do: Map.put(account_update_params, "email", account_token.candidate_email),
        else: account_update_params

    multi =
      Multi.new()
      |> Multi.update(:account, Account.changeset(account, account_update_params))
      |> Multi.delete(:account_token_delete, account_token)
      |> Multi.insert(
        :log,
        fn %{account: %Account{id: account_id}} ->
          Log.changeset(%Log{account_id: account_id}, %{action: log_action})
        end
      )

    Repo.transaction(multi)
  end

  def create_account_token(attrs \\ %{}) do
    %AccountToken{}
    |> AccountToken.changeset(attrs)
    |> Repo.insert()
  end

  def create_account_token_remove_old_token_transaction(attrs) do
    Multi.new()
    |> Multi.delete_all(
      :old_token,
      from(t in AccountToken, where: t.account_id == ^attrs.account_id and t.type == ^attrs.type)
    )
    |> Multi.insert(:token, AccountToken.changeset(%AccountToken{}, attrs))
    |> Repo.transaction()
  end

  def delete_account_token(%AccountToken{} = account_token) do
    Repo.delete(account_token)
  end

  def update_account_token(%AccountToken{} = account_token, attrs) do
    account_token
    |> AccountToken.changeset(attrs)
    |> Repo.update()
  end

  def get_account_token(account_token, token_type) do
    max_validity = Application.get_env(:rc, RC.Accounts.AccountToken) |> Keyword.get(:validity_time)
    {:ok, time} = DateTime.from_unix(DateTime.to_unix(DateTime.utc_now()) - max_validity)

    Repo.one(
      from(t in AccountToken,
        where: t.value == ^account_token and t.type == ^token_type and t.inserted_at > ^time
      )
    )
  end

  @doc """
  Returns the list of accounts.

  ## Examples

      iex> list_accounts()
      [%Account{}, ...]

  """
  def list_accounts(params \\ %{}, preload_profiles? \\ false) do
    filtrex_params = Map.drop(params, ["page"])
    config = Account.filter_options()

    case Filtrex.parse_params(config, filtrex_params) do
      {:ok, filter} ->
        query =
          if preload_profiles? do
            from(a in Account, order_by: [desc: a.id], preload: :profiles)
          else
            from(a in Account, order_by: [desc: a.id])
          end

        accounts =
          Filtrex.query(query, filter)
          |> RC.Repo.paginate(params)

        {:ok, accounts}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account(123)
      %Account{}

      iex> get_account(456)
      nil

  """
  def get_account(id), do: Repo.get(Account, id)

  def get_account!(id), do: Repo.get!(Account, id)

  def get_account_preload(id) do
    from(a in Account, where: [id: ^id], preload: [:profiles, :groups, :money_transactions])
    |> Repo.one()
  end

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.changeset_password(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  def update_account_money(trx, %Account{} = account, amount, reason) do
    trx
    |> Multi.update(:account_money, Ecto.Changeset.change(account, money: account.money + amount))
    |> Multi.insert(:money_transaction, fn %{account_money: %Account{id: account_id, money: money}} ->
      money_transaction = %{"amount" => amount, "money" => money, "reason" => reason, "account_id" => account_id}
      MoneyTransaction.changeset(%MoneyTransaction{}, money_transaction)
    end)
  end

  def upgrade_account(%Account{} = account, steam_id) do
    account
    |> Account.changeset(%{steam_id: steam_id})
    |> Account.changeset_is_free(false)
    |> Repo.update()
  end

  @doc """
  Updates an account and send a verification email if needed.
  """
  def update_account_transaction(
        %Account{} = account,
        account_update_params,
        token_params,
        mailer,
        email_template
      ) do
    trx =
      account_update_transaction(
        account,
        account_update_params,
        token_params,
        mailer,
        email_template
      )

    Repo.transaction(trx)
  end

  defp account_update_transaction(
         %Account{} = account,
         account_update_params,
         token_params,
         mailer,
         email_template
       ) do
    # if mail in the update and mail verification we store the candidate email in the token and send a verification email
    if token_params do
      account_update_params = Map.drop(account_update_params, ["email"])

      trx =
        Multi.new()
        |> Multi.update(:account, Account.changeset(account, account_update_params))

      if token_params,
        do:
          trx
          |> Multi.delete_all(
            :old_token,
            from(t in AccountToken, where: t.account_id == ^account.id and t.type == :email_update)
          )
          |> Multi.insert(:account_token, fn %{account: %Account{id: account_id}} ->
            AccountToken.changeset_email(%AccountToken{account_id: account_id}, token_params)
          end)
          |> Multi.run(:send_email, fn _repo, %{account: account, account_token: account_token} ->
            mailer.(account, account_token, email_template)
          end),
        else: trx
    else
      Multi.new()
      |> Multi.update(:account, Account.changeset(account, account_update_params))
    end
  end

  @doc """
  Deletes a Account.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account(account)
      %Ecto.Changeset{source: %Account{}}

  """
  def change_account(%Account{} = account) do
    Account.changeset(account, %{})
  end

  @doc """
  Returns a list of Accounts that contains substring `search_string` in their name or email field.
  """
  def search_accounts(params, search_string) do
    pattern = "%" <> search_string <> "%"

    from(account in Account,
      where: ilike(account.email, ^pattern) or ilike(account.name, ^pattern)
    )
    |> RC.Repo.paginate(params)
  end

  @doc """
  Create a verification token and send an verification email using email provider
  """
  def send_verification(email, type) do
    token_value = AccountToken.new()

    template =
      if type == :password_reset,
        do: :password_reset_template,
        else: :verification_template

    with {:ok, account} <- get_account_by_email(email),
         {:ok, %{token: account_token}} <-
           create_account_token_remove_old_token_transaction(%{
             value: token_value,
             type: type,
             account_id: account.id
           }),
         {:ok, _} <- send_email_template(account, account_token, template) do
      if type == :password_reset,
        do: {:ok, :password_reset_sent},
        else: {:ok, :email_verification_sent}
    else
      {:error, reason} ->
        {:error, reason}

      {:error, failed_operation, failed_value, _changes_so_far} ->
        {:error, {failed_operation, failed_value}}
    end
  end

  @doc """
  Send email with given template
  """
  def send_email_template(account, token, template) do
    base_url = Application.get_env(:rc, :rc_domain)
    email_variables = get_email_variables(base_url, token, template)
    mailer_config = Application.get_env(:rc, RC.Mailer)
    sender = Keyword.get(mailer_config, :sender)
    template_id = Keyword.get(mailer_config, template)

    email =
      Swoosh.Email.new()
      |> to_destination(account, token, template)
      |> Swoosh.Email.from(sender)
      |> Swoosh.Email.put_provider_option(:template_id, template_id)
      |> Swoosh.Email.put_provider_option(:template_language, true)
      |> Swoosh.Email.put_provider_option(:variables, email_variables)

    Mailer.deliver(email)
  end

  defp get_email_variables(base_url, token, :email_update_template),
    do: %{validation_link: base_url <> "login/?action=validate-email-update&token=#{token.value}"}

  defp get_email_variables(base_url, token, :verification_template),
    do: %{validation_link: base_url <> "login/?action=validate-registration&token=#{token.value}"}

  defp get_email_variables(base_url, token, :web_bind_template),
    do: %{validation_link: base_url <> "bind/?token=#{token.value}"}

  defp get_email_variables(base_url, token, :password_reset_template),
    do: %{reset_password_link: base_url <> "reset-password/?token=#{token.value}"}

  defp to_destination(mail, account, token, :email_update_template),
    do: Swoosh.Email.to(mail, {account.name, token.candidate_email})

  defp to_destination(mail, account, token, :web_bind_template),
    do: Swoosh.Email.to(mail, {account.name, token.candidate_email})

  defp to_destination(mail, account, _token, _template),
    do: Swoosh.Email.to(mail, {account.name, account.email})

  @doc """
  Returns the list of profiles.

  ## Examples

      iex> list_profiles()
      [%Profile{}, ...]

  """
  def list_profiles(params) do
    filtrex_params = Map.drop(params, ["page", "aid"])
    config = Profile.filter_options()

    case Filtrex.parse_params(config, filtrex_params) do
      {:ok, filter} ->
        query = from(i in Profile, order_by: [desc: i.id])

        profiles =
          Filtrex.query(query, filter)
          |> RC.Repo.paginate(params)

        {:ok, profiles}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Returns the list of profiles.

  ## Examples

      iex> list_profiles()
      [%Profile{}, ...]

  """
  def list_profiles_by_account(params, account_id) do
    filtrex_params = Map.take(params, ["account_id"])
    config = Profile.filter_options()

    case Filtrex.parse_params(config, filtrex_params) do
      {:ok, filter} ->
        query =
          from(profile in Profile,
            as: :profile,
            left_join: registration in assoc(profile, :registrations),
            left_join: faction in assoc(registration, :faction),
            left_join: instance in assoc(faction, :instance),
            left_lateral_join:
              last in subquery(
                from(reg in RC.Instances.Registration,
                  where: [profile_id: parent_as(:profile).id],
                  order_by: [desc: reg.updated_at],
                  limit: 1,
                  select: [:id]
                )
              ),
            on: last.id == registration.id,
            preload: [registrations: {registration, faction: {faction, instance: instance}}],
            where: profile.account_id == ^account_id,
            distinct: profile.id,
            order_by: [desc: profile.id]
          )

        profiles =
          Filtrex.query(query, filter)
          |> RC.Repo.paginate(params)

        {:ok, profiles}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Returns a list of Profiles that contains substring `search_string` in their name or full name field.
  """
  def search_profiles(params, search_string) do
    pattern = "%" <> search_string <> "%"

    from(profile in Profile,
      where: ilike(profile.name, ^pattern) or ilike(profile.full_name, ^pattern)
    )
    |> RC.Repo.paginate(params)
  end

  def search_profiles_in_instance(params, instance_id, search_string) do
    pattern = "%" <> search_string <> "%"

    from(profile in Profile,
      left_join: registration in assoc(profile, :registrations),
      left_join: faction in assoc(registration, :faction),
      where: faction.instance_id == ^instance_id,
      where: ilike(profile.name, ^pattern) or ilike(profile.full_name, ^pattern)
    )
    |> RC.Repo.paginate(params)
  end

  def list_profiles_by_faction(faction_id) do
    from(profile in Profile,
      left_join: registration in assoc(profile, :registrations),
      left_join: faction in assoc(registration, :faction),
      where: faction.id == ^faction_id
    )
    |> Repo.all()
  end

  def own_profile?(account_id, profile_id) do
    Repo.exists?(
      from(p in Profile,
        join: a in Account,
        on: p.account_id == a.id,
        where: p.id == ^profile_id and a.id == ^account_id
      )
    )
  end

  @doc """
  Gets a single profile.

  Raises `Ecto.NoResultsError` if the Profile does not exist.

  ## Examples

      iex> get_profile(123)
      %Profile{}

      iex> get_profile(456)
      nil

  """
  def get_profile(id), do: Repo.get(Profile, id)

  def get_profile!(id), do: Repo.get!(Profile, id)

  def get_profile_preload(id) do
    from(profile in Profile,
      as: :profile,
      left_join: registration in assoc(profile, :registrations),
      left_join: faction in assoc(registration, :faction),
      left_join: instance in assoc(faction, :instance),
      preload: [registrations: {registration, faction: {faction, instance: instance}}],
      where: profile.id == ^id,
      distinct: profile.id,
      order_by: [desc: profile.id]
    )
    |> Repo.one()
  end

  @doc """
  Creates a profile.

  ## Examples

      iex> create_profile(%{field: value})
      {:ok, %Profile{}}

      iex> create_profile(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_profile(attrs \\ %{}) do
    %Profile{}
    |> Profile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a profile.

  ## Examples

      iex> update_profile(profile, %{field: new_value})
      {:ok, %Profile{}}

      iex> update_profile(profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_profile(%Profile{} = profile, attrs) do
    profile
    |> Profile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Profile.

  ## Examples

      iex> delete_profile(profile)
      {:ok, %Profile{}}

      iex> delete_profile(profile)
      {:error, %Ecto.Changeset{}}

  """
  def delete_profile(%Profile{} = profile) do
    Repo.delete(profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking profile changes.

  ## Examples

      iex> change_profile(profile)
      %Ecto.Changeset{source: %Profile{}}

  """
  def change_profile(%Profile{} = profile) do
    Profile.changeset(profile, %{})
  end

  @doc """
  Returns :ok if the account did not reached the profile limit.
  """
  def profiles_slot_available?(account_id) do
    profiles_limit = Application.get_env(:rc, RC.Accounts.Profile) |> Keyword.get(:limit)

    case from(p in Profile, where: p.account_id == ^account_id)
         |> Repo.aggregate(:count) do
      count when count < profiles_limit -> :ok
      _ -> :error
    end
  end

  @doc """
  Returns `{:ok, account}` for a valid email and password
  """
  def get_account_by_email_and_password(nil, _), do: {:error, :invalid}
  def get_account_by_email_and_password(_, nil), do: {:error, :invalid}

  def get_account_by_email_and_password(email, password) do
    # only accept active user
    with %Account{} = account <- get_active_account_by_email(email),
         true <- Argon2.verify_pass(password, account.hashed_password) do
      {:ok, account}
    else
      _ ->
        # Help to mitigate timing attacks
        Argon2.no_user_verify()
        {:error, :unauthorized}
    end
  end

  @doc """
  Returns `{:ok, account}` for a valid email and password
  """
  def get_account_by_steam_ticket(nil, _), do: {:error, :invalid}
  def get_account_by_steam_ticket(_, nil), do: {:error, :invalid}

  def get_account_by_steam_ticket(steam_id, ticket) do
    # only accept active user
    with {:ok, _} <- Portal.SteamController.ticket_check(ticket),
         %Account{} = account <- get_active_account_by_steam_id(steam_id) do
      {:ok, account}
    else
      _ ->
        {:error, :unauthorized}
    end
  end

  defp get_active_account_by_email(email) do
    email = String.downcase(email)

    Repo.one(
      from(
        a in Account,
        where: fragment("lower(?)", a.email) == fragment("lower(?)", ^email) and a.status == "active"
      )
    )
  end

  defp get_active_account_by_steam_id(steam_id) do
    Repo.one(from(a in Account, where: a.steam_id == ^steam_id and a.status == "active"))
  end

  def get_account_by_email(email) do
    email = String.downcase(email)

    case Repo.one(
           from(
             a in Account,
             where: fragment("lower(?)", a.email) == fragment("lower(?)", ^email)
           )
         ) do
      %Account{} = account -> {:ok, account}
      _ -> {:error, "Account not found"}
    end
  end

  def get_account_by_profile(pid) do
    Repo.one(
      from(a in Account,
        join: p in Profile,
        on: p.account_id == a.id,
        where: p.id == ^pid
      )
    )
  end
end
