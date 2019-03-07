defmodule TodoApp.Application do
  use Application

  def start(_type, _args) do
    children = [
      TodoApp.ProcessRegistry,
      TodoApp.Database,
      TodoApp.Cache
    ]

    opts = [strategy: :one_for_one, name: TodoApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
