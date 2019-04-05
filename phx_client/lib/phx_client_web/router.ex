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

  pipeline :todos do
    plug(:put_layout, {PhxClientWeb.LayoutView, :todos})
  end

  # pipeline :api do
  #   plug(:accepts, ["json"])
  # end

  scope "/", PhxClientWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/heartbeat", HeartbeatController, :index)

    live("/counter", CounterLive)


  end

  scope "/todos", PhxClientWeb do
    pipe_through(:browser)
    pipe_through(:todos)

    get("/:list_id", TodosController, :todo_list)
    get("/", TodosController, :global_list)
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhxClientWeb do
  #   pipe_through :api
  # end
end
