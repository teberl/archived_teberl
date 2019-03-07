defmodule TodoApp.DatabaseWorker do
  use GenServer

  def start_link(db_folder) do
    GenServer.start_link(
      __MODULE__,
      db_folder
    )
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  def store(pid, key, data) do
    GenServer.cast(pid, {:store, key, data})
  end

  def remove(pid, key) do
    GenServer.cast(pid, {:remove, key})
  end

  @impl GenServer
  def init(db_folder) do
    File.mkdir_p!(db_folder)
    {:ok, db_folder}
  end

  @impl GenServer
  def handle_cast({:store, key, data}, db_folder) do
    spawn(fn ->
      key
      |> file_name(db_folder)
      |> File.write!(:erlang.term_to_binary(data))
    end)

    {:noreply, db_folder}
  end

  @impl GenServer
  def handle_cast({:remove, key}, db_folder) do
    spawn(fn ->
      key
      |> file_name(db_folder)
      |> File.rm()
    end)

    {:noreply, db_folder}
  end

  @impl GenServer
  def handle_call({:get, key}, caller, db_folder) do
    spawn(fn ->
      data =
        case File.read(file_name(key, db_folder)) do
          {:ok, contents} -> :erlang.binary_to_term(contents)
          _ -> nil
        end

      GenServer.reply(caller, data)
    end)

    {:noreply, db_folder}
  end

  defp file_name(key, db_folder), do: Path.join(db_folder, to_string(key))
end
