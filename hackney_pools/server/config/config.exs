use Mix.Config

config :server, ServerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "lOMlBh9Y7gPRy7/1bb4gbEMtddlLiri+odctuIP2j9cgG1Dg+n44dBS/fU3NR51g",
  render_errors: [view: ServerWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Server.PubSub,
  live_view: [signing_salt: "MM5Cf74U"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"
