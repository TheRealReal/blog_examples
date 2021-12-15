defmodule Client.Pool.Worker do
  @moduledoc """
  A worker keeps the state of a metric
  """
  use GenServer

  @default_options [
    report_interval: 1_000
  ]

  #
  # Public API
  #

  @doc """
  Starts a new Worker process.

  - metric: the name of the metric - required.
  - report_interval: the interval, in milliseconds, on which the state will be
    reported to telemetry - optional, defaults to `1_000`
  """
  def start_link(args) do
    options = Keyword.merge(@default_options, args)
    metric = options[:metric] || raise "metric is missing"

    GenServer.start_link(__MODULE__, options, name: name_from_metric(metric))
  end

  @doc """
  Updates a metric state with the given value and using the given transform_fun.
  """
  def update(metric, value, transform_fun) do
    metric
    |> name_from_metric()
    |> GenServer.cast({:update, value, transform_fun})
  end

  @doc """
  Creates a :via tuple to name worker processes based on the metric name
  """
  def name_from_metric(metric) do
    {:via, Registry, {Client.Registry, metric}}
  end

  #
  # GenServer implementation
  #

  def child_spec(args) do
    %{
      id: {__MODULE__, args[:metric]},
      start: {__MODULE__, :start_link, [args]}
    }
  end

  @impl true
  def init(args) do
    metric = args[:metric]

    # This tuple has the pre computed data that we'll send to telemetry. It has
    # the format {tag, key, metadata}
    telemetry_settings =
      case metric do
        # Hackney global metric
        [:hackney, metric_key] ->
          {[:hackney], metric_key, %{}}

        # Hackney pool metric
        [:hackney_pool, pool_name, metric_key] ->
          {[:hackney_pool], metric_key, %{pool: pool_name}}
      end

    state =
      args
      |> Map.new()
      |> Map.merge(%{
        value: 0,
        telemetry_settings: telemetry_settings
        })

    schedule_report(state.report_interval)

    {:ok, state}
  end

  # Handles async updates
  @impl true
  def handle_cast(
        {:update, value, transform_fun},
        %{value: current_value, report_interval: report_interval} = state
      ) do
    # Updated the metric value by transforming the current value using the transform function
    updated_value = transform_fun.(current_value, value)

    # Creates an update version of this process state
    updated_state = %{state | value: updated_value}

    # If scheduled reports are disabled, report it right away
    if report_interval == 0, do: report(updated_state)

    {:noreply, updated_state}
  end

  # Handle async reports
  @impl true
  def handle_info(:report, state) do
    report(state)
    schedule_report(state.report_interval)

    {:noreply, state}
  end

  #
  # Helper functions
  #

  defp report(%{telemetry_settings: telemetry_settings, value: value}) do
    {metric, measurement_key, metadata} = telemetry_settings
    measurement = %{measurement_key => value}

    :telemetry.execute(metric, measurement, metadata)
  end

  # Schedules the next report to called in `report_interval_ms`.
  defp schedule_report(report_interval_ms) when report_interval_ms > 0 do
    Process.send_after(self(), :report, report_interval_ms)
  end

  defp schedule_report(_report_interval), do: :ok
end
