defmodule TodoApp.Server do
  use GenServer, restart: :temporary

  alias TodoApp.{Entry, List, Database, ProcessRegistry}

  @expiry_idle_timeout :timer.seconds(60 * 10)

  def start_link(list_name) do
    GenServer.start_link(
      __MODULE__,
      list_name,
      name: via_tuple(list_name)
    )
  end

  def put(pid, %Entry{} = entry), do: GenServer.cast(pid, {:put, entry})

  def delete(pid, id) when is_integer(id), do: GenServer.cast(pid, {:delete, id})

  @spec get(atom() | pid() | {atom(), any()} | {:via, atom(), any()}) :: any()
  def get(pid), do: GenServer.call(pid, {:get_all})
  def get(pid, id) when is_integer(id), do: GenServer.call(pid, {:get_by_id, id})
  def get(pid, %Date{} = date), do: GenServer.call(pid, {:get_by_date, date})
  def get(pid, _), do: GenServer.call(pid, {:get_all})

  def clear_completed(pid), do: GenServer.cast(pid, {:clear_completed})

  def toggle_complete(pid, id) when is_integer(id) do
    GenServer.call(pid, {:toggle_complete, id})
  end

  def update(pid, {id, title}) do
    GenServer.cast(pid, {:update, {id, title}})
  end

  @impl GenServer
  def init(list_name) do
    IO.puts("Starting server for #{list_name}")

    send(self(), {:real_init, list_name})
    {:ok, nil}
  end

  @impl GenServer
  def handle_info({:real_init, list_name}, _state) do
    {:noreply, {list_name, Database.get(list_name) || List.new()}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_info(:timeout, {list_name, list} = _state) do
    IO.puts("Stopping idle server #{list_name}")
    {:stop, :normal, {list_name, list}}
  end

  @impl GenServer
  def handle_cast({:put, entry}, {list_name, list} = _state) do
    new_list = List.add(list, entry)
    Database.store(list_name, new_list)
    {:noreply, {list_name, new_list}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_cast({:delete, id}, {list_name, list} = _state) do
    new_list = List.delete(list, id)
    Database.store(list_name, new_list)
    {:noreply, {list_name, new_list}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_cast({:clear_completed}, {list_name, list} = _state) do
    new_list = List.get_list(list, :active)
    Database.store(list_name, new_list)
    {:noreply, {list_name, new_list}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_cast({:update, {id, title}}, {list_name, list} = _state) do
    new_list = List.update(list, {id, title})
    Database.store(list_name, new_list)
    {:noreply, {list_name, new_list}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_call({:get_all}, _, {_list_name, list} = state) do
    {:reply, List.get_entries(list), state, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_call({:get_by_date, date}, _, {_list_name, list} = state) do
    {:reply, List.get_entries(list, date), state, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_call({:get_by_id, id}, _, {_list_name, list} = state) do
    {:reply, List.get_entries(list, id), state, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_call({:toggle_complete, id}, _, {list_name, list} = _state) do
    new_list = List.toggle_complete(list, id)
    Database.store(list_name, new_list)
    {:reply, Map.values(new_list.entries), {list_name, new_list}, @expiry_idle_timeout}
  end

  defp via_tuple(name) do
    ProcessRegistry.via_tuple({__MODULE__, name})
  end
end
