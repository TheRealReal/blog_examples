defmodule ServerWeb.Router do
  use ServerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ServerWeb do
    pipe_through :api

    get("/resource", ResourceController, :index)
  end
end
