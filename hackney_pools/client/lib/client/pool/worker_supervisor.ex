defmodule Client.Pool.WorkerSupervisor do
  use Supervisor

  alias Client.Pool.Worker

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      {Worker, metric: [:hackney, :nb_requests]},
      {Worker, metric: [:hackney, :total_requests]},
      {Worker, metric: [:hackney, :finished_requests]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def start_worker(metric) do
    Supervisor.start_child(__MODULE__, {Worker, metric: metric})
  end

  def stop_worker(metric) do
    worker_name = Worker.name_from_metric(metric)
    Supervisor.delete_child(__MODULE__, worker_name)
  end
end
