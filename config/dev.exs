use Mix.Config

port = (not is_nil(System.get_env("PORT")) and String.to_integer(System.get_env("PORT"))) || 4000

config :rc,
  environment: :dev,
  disallow_mp3: true

watchers =
  if port == 4000 do
    [
      node: [
        "node_modules/webpack/bin/webpack.js",
        "--mode",
        "development",
        "--watch-stdin",
        cd: Path.expand("../assets", __DIR__)
      ],
      node: [
        "node_modules/.bin/vue-cli-service",
        "--stdin",
        "--port=8080",
        "serve",
        cd: Path.expand("../front", __DIR__)
      ]
    ]
  else
    []
  end

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.

config :rc, Portal.Endpoint,
  http: [port: port],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: watchers

# Configure your database
config :rc, RC.Repo,
  username: "postgres",
  password: "postgres",
  database: "gateway_dev",
  hostname: "localhost",
  pool_size: 10

# Watch static and templates for browser reloading.
config :portal, Portal.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/gateway_web/(live|views)/.*(ex)$",
      ~r"lib/gateway_web/templates/.*(eex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console,
  format: "[$level] $message\n",
  level: :warn

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Disable Appsignal
config :appsignal, :config, active: false

# Google Sheet data
config :goth,
  disabled: false,
  json: "./config/service_account.json" |> File.read!()

config :elixir_google_spreadsheets, :client,
  request_workers: 5,
  max_demand: 100,
  max_interval: :timer.minutes(1),
  interval: 100

dev_secret_path = Path.expand("config/dev.secret.exs")

if File.exists?(dev_secret_path) do
  import_config "dev.secret.exs"
end

config :libcluster,
  topologies: [
    game_servers: [
      strategy: Elixir.Cluster.Strategy.Gossip,
      config: [
        port: 45_892,
        if_addr: "0.0.0.0",
        multicast_if: "192.168.1.1",
        multicast_addr: "230.1.1.251",
        multicast_ttl: 1,
        secret: "somepassword"
      ]
    ]
  ]
