defmodule ServerWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :server

  @session_options [
    store: :cookie,
    key: "_server_key",
    signing_salt: "Uwg7FDMV"
  ]

  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug ServerWeb.Router
end
