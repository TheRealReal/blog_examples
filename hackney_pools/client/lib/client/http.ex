defmodule Client.HTTP do
  use HTTPoison.Base

  def get_resource(delay) do
    {elapsed_time, result} = :timer.tc(fn ->
      get("/resource?delay=#{delay}", [], hackney: [pool: :client_pool])
    end)

    case result do
      {:ok, %HTTPoison.Response{body: body}} ->
        {:ok, elapsed_time/1000, body}

      _ -> :error
    end
  end

  def process_request_url(path) do
    "http://localhost:4000" <> path
  end
end
