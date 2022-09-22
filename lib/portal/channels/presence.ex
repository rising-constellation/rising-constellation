defmodule Portal.Presence do
  use Phoenix.Presence,
    otp_app: :rc,
    pubsub_server: RC.PubSub
end
