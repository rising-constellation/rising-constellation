defmodule Portal.Endpoint do
  require EnvOnly

  use Phoenix.Endpoint, otp_app: :rc

  @session_options [
    store: :cookie,
    key: "_portal_key",
    signing_salt: "rWCMKEW0"
  ]

  socket("/socket", Portal.Socket,
    websocket: true,
    longpoll: false
  )

  socket("/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]])

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug(Plug.Static,
    at: "/",
    from: :rc,
    gzip: true
  )

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
    plug(Phoenix.Ecto.CheckRepoStatus, otp_app: :portal)
  end

  plug(Plug.RequestId)
  plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])

  EnvOnly.not_prod do
    plug(Plug.Logger)
  end

  EnvOnly.prod do
    plug(Plug.LoggerJSON, log: Logger.level())
  end

  plug(Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"
  )

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library(),
    length: 100_000_000
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)

  plug(Corsica,
    allow_credentials: true,
    allow_headers: :all,
    origins: [Application.get_env(:rc, :rc_domain)]
  )

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug(Plug.Session, @session_options)

  plug(Portal.Router)
end
