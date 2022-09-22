defmodule RC.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    {:ok, _} = Application.ensure_all_started(:appsignal)

    # List all child processes to be supervised
    children = [
      # Start the Game supervisor
      Game,
      {Phoenix.PubSub, [name: RC.PubSub, adapter: Phoenix.PubSub.PG2]},
      # Start the Ecto repository
      RC.Repo,
      # Start the endpoint when the application starts
      Portal.Endpoint,
      # Start Presence endpoint
      Portal.Presence,
      {Portal.ChannelWatcher, :player_channel},
      RC.GC
    ]

    children =
      children ++
        if Application.get_env(:rc, :environment) != :test do
          [
            %{
              type: :worker,
              id: :fix_instances_statuses,
              start: {Task, :start_link, [fn -> RC.Instances.update_instances_state_if_needed(true) end]},
              restart: :temporary,
              shutdown: 5000
            }
          ]
        else
          []
        end

    Supervisor.start_link(children, strategy: :one_for_one, name: RC.Supervisor)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Portal.Endpoint.config_change(changed, removed)
    :ok
  end
end
