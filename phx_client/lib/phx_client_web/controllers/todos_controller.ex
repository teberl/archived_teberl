defmodule PhxClientWeb.TodosController do
  use PhxClientWeb, :controller

  alias Phoenix.LiveView
  alias TodoApp.Cache

  @server "global"

  plug(:put_layout, :todos)

  def index(conn, _params) do
    pid = Cache.server_process(@server)

    conn
    |> LiveView.Controller.live_render(PhxClientWeb.TodosLive.Index,
      session: %{filter: :SHOW_ALL, pid: pid}
    )
  end

  def active(conn, _params) do
    pid = Cache.server_process(@server)

    conn
    |> LiveView.Controller.live_render(PhxClientWeb.TodosLive.Index,
      session: %{filter: :SHOW_ACTIVE, pid: pid}
    )
  end

  def completed(conn, _params) do
    pid = Cache.server_process(@server)

    conn
    |> LiveView.Controller.live_render(PhxClientWeb.TodosLive.Index,
      session: %{filter: :SHOW_COMPLETED, pid: pid}
    )
  end
end
