defmodule ServerWeb.ResourceController do
  use ServerWeb, :controller

  def index(conn, params) do
    delay =
      params
      |> Map.get("delay", "200")
      |> String.to_integer()

    :timer.sleep(delay)

    text(conn, "Slept for #{delay}ms!")
  end
end
