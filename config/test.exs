use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :rc, Portal.Endpoint,
  http: [port: 4002],
  server: false

config :rc,
  signup_mode: :mail_validation,
  rc_domain: "https://rising-constellation.com/",
  game_domain: "https://rising-constellation.com/game/"

config :rc, RC.Mailer, adapter: Swoosh.Adapters.Test

# Configure your database
config :rc, RC.Repo,
  username: "postgres",
  password: "postgres",
  database: "rc_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 100,
  # in microseconds, defaults to 50
  queue_target: 500,
  # in microseconds, defaults to 1000
  queue_interval: 2000,
  ownership_timeout: 20_000_000

# Use a much weaker hash in test env to speed up test suite
config :argon2_elixir, t_cost: 1, m_cost: 8

# Print only warnings and errors during test
config :logger, level: :warn
