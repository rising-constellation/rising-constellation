defmodule RC.Guardian do
  use Guardian, otp_app: :rc

  def subject_for_token(%{id: account_id}, _claims) do
    {:ok, to_string(account_id)}
  end

  def subject_for_token(_, _) do
    {:error, :no_resource_id}
  end

  def resource_from_claims(%{"sub" => account_id}) do
    case RC.Accounts.get_account(account_id) do
      nil -> {:error, :no_claims_sub}
      account -> {:ok, account}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :no_claims_sub}
  end

  def resource_from_session(session) do
    {:ok, user, _guardian} = Guardian.resource_from_token(RC.Guardian, session["guardian_default_token"])
    user
  end
end
