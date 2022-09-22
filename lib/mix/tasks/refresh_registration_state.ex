defmodule Mix.Tasks.RefreshRegistrationState do
  @shortdoc "Refresh registration state with most the value of the most recent registration_state"

  use Mix.Task

  alias RC.Instances.Registration
  alias RC.Instances.RegistrationState
  alias RC.Registrations
  alias RC.Repo

  import Ecto.Query, warn: false

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")

    from(r in Registration,
      where: r.state == "placeholder"
    )
    |> Repo.all()
    |> Enum.each(fn reg ->
      last_state =
        from(s in RegistrationState,
          where: s.registration_id == ^reg.id,
          order_by: [desc: s.id],
          limit: 1
        )
        |> Repo.one()

      {:ok, _reg} = Registrations.update(reg, %{state: last_state.state})
    end)
  end
end
