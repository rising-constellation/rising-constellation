defmodule RC.MixProject do
  use Mix.Project

  def project do
    [
      app: :rc,
      version: "0.1.0",
      build_path: "_build",
      config_path: "config/config.exs",
      deps_path: "deps",
      lockfile: "mix.lock",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
      releases: [
        rc: [
          include_executables_for: [:unix],
          applications: [runtime_tools: :permanent]
        ]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {RC.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools,
        :os_mon,
        :ueberauth,
        :ueberauth_identity,
        :scrivener_ecto,
        :appsignal,
        :plug_logger_json
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:appsignal, "~> 2.0"},
      {:argon2_elixir, "~> 2.0"},
      {:behavior_tree, "~> 0.3.1"},
      {:corsica, "~> 1.0"},
      {:credo, "~> 1.2", only: [:dev, :test], runtime: false},
      {:csv, "~> 2.3"},
      {:collision, "~> 0.3.1"},
      {:ddrt, git: "https://github.com/windfish-studio/ddrt.git", ref: "3c0ba6defbfaad392e5ee41a7aae25c937a21058"},
      {:decorator, "~> 1.2"},
      {:earmark, "~> 1.4.5"},
      {:ecto_autoslug_field, "~> 2.0"},
      {:ecto_enum, "~> 1.4"},
      {:ecto_psql_extras, "~> 0.4"},
      {:ecto_sql, "~> 3.4"},
      {:elixir_google_spreadsheets, "~> 0.1.17"},
      {:email_guard, "~> 1.0"},
      {:ex_aws_s3, "~> 2.0"},
      {:ex_aws, "~> 2.1.2"},
      {:ex_doc, "~> 0.23.0", only: :dev},
      {:excoveralls, "~> 0.13", only: :test},
      {:filtrex, "~> 0.4.3"},
      {:floki, ">= 0.0.0", only: :test},
      {:gelf_logger, "~> 0.10"},
      {:gettext, "~> 0.18"},
      {:guardian_phoenix, "~> 2.0"},
      {:guardian, "~> 2.1.1"},
      {:hackney, "~> 1.9"},
      {:horde, "~> 0.8.3"},
      {:html_sanitize_ex, "~> 1.4"},
      {:jason, "~> 1.0"},
      {:libcluster, "~> 3.2"},
      {:libgraph, "~> 0.13"},
      {:machinery, "~> 1.0.0"},
      {:number, "~> 1.0.0"},
      {:phoenix_ecto, "~> 4.1"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_dashboard, "~> 0.4.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.15.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix, "~> 1.5.3"},
      {:plug_cowboy, "~> 2.0"},
      {:plug_logger_json, "~> 0.7.0"},
      {:postgrex, ">= 0.0.0"},
      {:puid, "~> 1.0"},
      {:rexbug, "~> 1.0"},
      {:scrivener_ecto, "~>2.2"},
      {:scrivener_headers, "~> 3.1"},
      {:stripity_stripe, "~> 2.0"},
      {:sweet_xml, "~> 0.6"},
      {:swoosh, "~> 1.0"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 0.5"},
      {:terraform, "~> 1.0.1", only: :dev},
      {:typed_struct, "~> 0.2"},
      {:ueberauth_identity, "~> 0.3"},
      {:ueberauth, "~> 0.6"},
      {:waffle_ecto, "~> 0.0.9"},
      {:waffle, "~> 1.1.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "puppet.setup": ["run priv/repo/puppets.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
