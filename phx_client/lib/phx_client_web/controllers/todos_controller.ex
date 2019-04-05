defmodule PhxClientWeb.TodosController do
  use PhxClientWeb, :controller

  alias Phoenix.LiveView
  alias TodoApp.Cache

  @server "global"

  def global_list(conn, _params) do
    pid = Cache.server_process(@server)

    conn
    |> LiveView.Controller.live_render(PhxClientWeb.TodosLive.Index,
      session: %{filter: :SHOW_ALL, pid: pid, list_id: @server }
    )
  end

  def todo_list(conn, %{"list_id" => list_id} = params) do
    pid = Cache.server_process(list_id)
    filter = case Map.get(params, "filter", "all") do
      "active" -> :SHOW_ACTIVE
      "completed" -> :SHOW_COMPLETED
      "all" -> :SHOW_ALL
      _ -> :SHOW_ALL
    end

    conn
    |> LiveView.Controller.live_render(PhxClientWeb.TodosLive.Index,
      session: %{filter: filter, list_id: list_id, pid: pid}
    )
  end

end
