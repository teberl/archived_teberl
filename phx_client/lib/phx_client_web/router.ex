defmodule PhxClientWeb.Router do
  use PhxClientWeb, :router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(Phoenix.LiveView.Flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:put_layout, {PhxClientWeb.LayoutView, :app})
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", PhxClientWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/heartbeat", HeartbeatController, :index)

    live("/counter", CounterLive)

    get("/todos", TodosController, :index)
    get("/todos/active", TodosController, :active)
    get("/todos/completed", TodosController, :completed)
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhxClientWeb do
  #   pipe_through :api
  # end
end
