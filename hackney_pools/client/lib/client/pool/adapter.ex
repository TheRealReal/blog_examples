defmodule Client.Pool.Adapter do
  @moduledoc """
  An adapter that listens for events from hackney and translates it to our
  telemetry-based metrics engine.
  """

  alias Client.Pool.{Worker, WorkerSupervisor}

  @doc """
  Creates a new listener for the given metric.

  This will spawn a new process that will keep the state of this metric and
  report it to telemetry.
  """
  def new(type, metric)

  # Ignore hackney global metrics as they are always started
  def new(_type, [:hackney, _]), do: :ok

  def new(_type, metric) do
    WorkerSupervisor.start_worker(metric)
  end

  @doc """
  Stops the listener of the given metric.
  """
  def delete(metric) do
    WorkerSupervisor.stop_worker(metric)
  end

  @doc """
  Increments a counter specified by `metric` by `value` - defaults to 1.
  """
  def increment_counter(metric, value \\ 1), do: Worker.update(metric, value, &sum/2)

  @doc """
  Decrements a counter specified by `metric` by `value` - defaults to 1.
  """
  def decrement_counter(metric, value \\ 1), do: Worker.update(metric, -1 * value, &sum/2)

  @doc """
  Updates a histogram
  """
  def update_histogram(metric, value_or_fun)

  def update_histogram(metric, fun) when is_function(fun, 0),
    do: Worker.update(metric, fun, &eval_and_replace/2)

  # There is a bug on hackney that will make the following metrics have a shift
  # of -1 on their value:
  # - [:hackney_pool, <pool_name>, :free_count]
  # - [:hackney_pool, <pool_name>, :in_use_count]
  #
  # For these metrics, we fix their value by adding +1.
  #
  # Reference: https://github.com/benoitc/hackney/blob/592a00720cd1c8eb1edb6a6c9c8b8a4709c8b155/src/hackney_pool.erl#L597-L604
  def update_histogram([:hackney_pool, _pool, metric] = metric_name, value)
      when metric in [:in_use_count, :free_count] do
    Worker.update(metric_name, value + 1, &replace/2)
  end

  def update_histogram(metric, value), do: Worker.update(metric, value, &replace/2)

  @doc """
  Updates the gauge of the given metric by replacing the current value with a
  new value.
  """
  def update_gauge(metric, value), do: Worker.update(metric, value, &replace/2)

  @doc """
  Updates the meter of the given metric by summing the current value with the
  new value.
  """
  def update_meter(metric, value), do: Worker.update(metric, value, &sum/2)

  #
  # Transform functions
  #

  defp sum(state, value), do: state + value
  defp replace(_state, value), do: value
  defp eval_and_replace(_state, fun), do: fun.()
end
