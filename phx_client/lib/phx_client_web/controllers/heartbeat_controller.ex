defmodule PhxClientWeb.HeartbeatController do
  use PhxClientWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
