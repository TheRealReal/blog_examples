defmodule Client.Telemetry do
  use Supervisor
  import Telemetry.Metrics

  require Logger

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    children = [
      {:telemetry_poller, [measurements: periodic_measurements(), period: 5_000]}
    ]

    :ok = :telemetry.attach("super-simple-pool-monitor", [:hackney_pool], &handle_pool_event/4, nil)

    Supervisor.init(children, strategy: :one_for_one)
  end

def handle_pool_event(_event, measurements, %{pool: pool}, _config) do
  case measurements do
    %{queue_count: queue_count} when queue_count > 0 ->
      Logger.warn("⚠️ #{pool} is full! #{queue_count} requests in queue! ⚠️")

    _ ->
      :ok
    end
end

  defp metrics do
    pool_metric_options = [tags: [:pool]]

    [
      # Hackney General Metrics
      last_value("hackney.nb_requests"),
      last_value("hackney.total_request"),
      last_value("hackney.finished_requests"),

      # Hackney Pool Metrics
      last_value("hackney_pool.take_rate", pool_metric_options),
      last_value("hackney_pool.no_socket", pool_metric_options),
      last_value("hackney_pool.in_use_count", pool_metric_options),
      last_value("hackney_pool.free_count", pool_metric_options),
      last_value("hackney_pool.queue_count", pool_metric_options)
    ]
  end

  # A module, function and arguments to be invoked periodically.
  # This function must call :telemetry.execute/3 and a metric must be added above.
  # {TheRealRealWeb, :count_users, []}
  defp periodic_measurements, do: []
end
