defmodule Client.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Client.Telemetry,
      {Registry, name: Client.Registry, keys: :unique},
      Client.Pool.WorkerSupervisor,
      :hackney_pool.child_spec(:client_pool, max_connections: 3, timeout: 3000)
    ]

    opts = [strategy: :one_for_one, name: Client.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
