defmodule PhxClientWeb.Router do
  use PhxClientWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PhxClientWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/heartbeat", HeartbeatController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhxClientWeb do
  #   pipe_through :api
  # end
end
