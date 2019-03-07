defmodule TodoApp.Database do
  alias TodoApp.DatabaseWorker

  @pool_size 3
  @db_folder "./file_storage"

  def child_spec(_) do
    File.mkdir_p!(@db_folder)

    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: DatabaseWorker,
        size: @pool_size
      ],
      [@db_folder]
    )
  end

  def get(key) do
    :poolboy.transaction(__MODULE__, fn worker_pid -> DatabaseWorker.get(worker_pid, key) end)
  end

  def store(key, data) do
    :poolboy.transaction(__MODULE__, fn worker_pid ->
      DatabaseWorker.store(worker_pid, key, data)
    end)
  end

  def remove(key) do
    :poolboy.transaction(__MODULE__, fn worker_pid -> DatabaseWorker.remove(worker_pid, key) end)
  end
end
