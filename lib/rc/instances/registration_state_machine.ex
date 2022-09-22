defmodule RC.Instances.RegistrationStateMachine do
  alias Ecto.Multi
  alias RC.Accounts
  alias RC.Instances.Registration
  alias RC.Instances.RegistrationState
  alias RC.Repo

  require Logger

  use Machinery,
    states: ["joined", "playing", "resigned", "dead"],
    transitions: %{
      "joined" => ["playing"],
      "playing" => ["resigned", "dead"]
    }

  def log_transition(%Registration{id: rid} = registration, next_state) do
    {:ok, _registration_state} = create_registration_state(%{registration_id: rid, state: next_state})
    registration
  end

  def after_transition(%Registration{} = registration, _state) do
    profile = Accounts.get_profile(registration.profile_id)

    case profile do
      {:error, reason} -> Logger.error("#{reason}")
      _ -> nil
    end

    registration
  end

  defp create_registration_state(%{registration_id: rid, state: state} = attrs) do
    registration_state = RegistrationState.changeset(%RegistrationState{}, attrs)

    registration =
      Repo.get_by(Registration, id: rid)
      |> Registration.changeset(%{state: state})

    Multi.new()
    |> Multi.insert(:registration_state, registration_state)
    |> Multi.update(:registration, registration)
    |> Repo.transaction()
  end
end
