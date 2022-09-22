defmodule Portal.ProfileController do
  @moduledoc """
  The Profile controller.

  ### Logged in and `:aid` is corresponding to the logged in account:
  Creates a Profile:
      POST /accounts/:aid/profiles, body: %{profile: profile_params}
  Get all the profiles of an account:
      GET /accounts/:aid/profiles

  ### Logged in and the account own the profile:
  Update a profile:
      PUT /profiles/:pid, body: %{profile: profile_params}
  Delete a profile:
      DELETE /profiles/:pid

  ### Logged in:
  Show a profile:
      GET /profiles/:pid

  Beeing an admin bypasses all the rules.

  """
  use Portal, :controller

  alias RC.Accounts
  alias RC.Accounts.Profile

  require Logger

  action_fallback(Portal.FallbackController)

  def index_by_account(conn, %{"aid" => account_id} = params) do
    case Accounts.list_profiles_by_account(params, account_id) do
      {:ok, profiles} ->
        conn
        |> Scrivener.Headers.paginate(profiles)
        |> render("index.json", profiles: profiles)

      {:error, error} ->
        conn
        |> put_status(400)
        |> json(%{message: error})
    end
  end

  def create(conn, %{"aid" => account_id, "profile" => profile_params}) do
    profile_params = Map.put(profile_params, "account_id", account_id)

    with :ok <- Accounts.profiles_slot_available?(account_id),
         {:ok, profile} <- Accounts.create_profile(profile_params) do
      conn
      |> put_status(:created)
      |> render("show.json", profile: profile)
    else
      :error ->
        conn
        |> put_status(403)
        |> json(%{message: :maximum_number_of_profiles_reached})

      error ->
        error
    end
  end

  def show(conn, %{"pid" => profile_id}) do
    case Accounts.get_profile(profile_id) do
      nil -> {:error, :not_found}
      profile -> render(conn, "show.json", profile: profile)
    end
  end

  def update(conn, %{"pid" => profile_id, "profile" => profile_params}) do
    with profile <- Accounts.get_profile(profile_id),
         {:ok, %Profile{} = profile} <- Accounts.update_profile(profile, profile_params) do
      render(conn, "show.json", profile: profile)
    else
      error -> error
    end
  end

  def delete(conn, %{"pid" => profile_id}) do
    with profile <- Accounts.get_profile(profile_id),
         {:ok, %Profile{}} <- Accounts.delete_profile(profile) do
      send_resp(conn, :no_content, "")
    else
      error -> error
    end
  end

  def search(conn, %{"query" => query}) do
    profiles = Accounts.search_profiles(%{page_size: 10}, query)
    render(conn, "index.json", profiles: profiles)
  end

  def search_instance(conn, %{"iid" => instance_id, "query" => query}) do
    profiles = Accounts.search_profiles_in_instance(%{page_size: 10}, instance_id, query)
    render(conn, "index.json", profiles: profiles)
  end
end
