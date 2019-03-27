defmodule PhxClientWeb.TodosLive.Index do
  use Phoenix.LiveView

  alias PhxClientWeb.TodosView
  alias TodoApp.Server

  def mount(%{pid: pid, filter: filter} = _session, socket) do
    todos = fetch(pid)

    default_assigns = %{
      pid: pid,
      filter: filter,
      new_todo: "",
      todos: filter_todos(todos, filter),
      active_count: active_count(todos),
      edit: nil
    }

    {:ok, assign(socket, default_assigns)}
  end

  defp fetch(pid), do: Server.get(pid)

  def render(assigns), do: TodosView.render("index.html", assigns)

  def handle_event(
        "header_add",
        %{"todo" => %{"title" => title}} = _value,
        %{assigns: %{pid: pid}} = socket
      ) do
    new_todo = create_todo(title)

    case new_todo do
      %TodoApp.Entry{} -> Server.put(pid, new_todo)
      nil -> nil
    end

    new_todos = fetch(pid)

    {:noreply, update_todos(socket, new_todos)}
  end

  def handle_event("todo_toggle", id, %{assigns: %{pid: pid}} = socket) do
    new_todos = Server.toggle_complete(pid, String.to_integer(id))

    {:noreply, update_todos(socket, new_todos)}
  end

  def handle_event("todo_delete", id, %{assigns: %{pid: pid}} = socket) do
    with :ok <- Server.delete(pid, String.to_integer(id)),
         new_todos = fetch(pid) do
      {:noreply, update_todos(socket, new_todos)}
    end
  end

  def handle_event("todo_click", id, %{assigns: %{edit: edit}} = socket) do
    id = String.to_integer(id)

    new_edit =
      cond do
        edit == id -> nil
        true -> id
      end

    {:noreply, assign(socket, %{edit: new_edit})}
  end

  def handle_event("todo_blur", new_title, socket) do
    socket = save(socket, new_title)
    {:noreply, socket}
  end

  def handle_event("todo_add", _form_value, socket) do
    {:noreply, socket}
  end

  def handle_event("footer_clear_completed", _, %{assigns: %{pid: pid}} = socket) do
    Server.clear_completed(pid)
    new_todos = fetch(pid)

    {:noreply, update_todos(socket, new_todos)}
  end

  defp filter_todos(todos, :SHOW_ACTIVE), do: Enum.filter(todos, &(!&1.completed))
  defp filter_todos(todos, :SHOW_COMPLETED), do: Enum.filter(todos, & &1.completed)
  defp filter_todos(todos, _), do: todos

  defp active_count(todos), do: Enum.count(todos, &(!&1.completed))

  defp create_todo(title) do
    cond do
      String.trim(title) == "" -> nil
      true -> new_todo(title)
    end
  end

  defp new_todo(title) when is_bitstring(title) do
    DateTime.utc_now()
    |> DateTime.to_date()
    |> TodoApp.Entry.new(title)
  end

  defp save(%{assigns: %{pid: pid, edit: id}} = socket, new_title) do
    Server.update(pid, {id, new_title})
    new_todos = fetch(pid)

    socket
    |> update_todos(new_todos)
    |> assign(%{edit: nil})
  end

  defp update_todos(%{assigns: %{filter: filter}} = socket, new_todos) do
    todos = filter_todos(new_todos, filter)
    active_count = active_count(new_todos)
    assign(socket, todos: todos, active_count: active_count)
  end
end
