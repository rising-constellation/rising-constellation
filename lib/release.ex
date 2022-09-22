defmodule RC.Release do
  @moduledoc """
  $ ./rc/bin/rc eval "RC.Release.migrate"

  """
  import Ecto.Query, warn: false

  @app :rc

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def migrate_registration_state do
    load_app()

    from(r in RC.Instances.Registration,
      where: r.state == "placeholder"
    )
    |> RC.Repo.all()
    |> Task.async_stream(fn reg ->
      last_state =
        from(s in RC.Instances.RegistrationState,
          where: s.registration_id == ^reg.id,
          order_by: [desc: s.id],
          limit: 1
        )
        |> RC.Repo.one()

      {:ok, _reg} = RC.Registrations.update(reg, %{state: last_state.state})
    end)
    |> Enum.to_list()
    |> Enum.count()
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
