defmodule TodoApp.List do
  @moduledoc """
  Functions for working with List's
  """

  alias __MODULE__
  alias TodoApp.Entry

  defstruct auto_id: 1, entries: %{}

  @doc """
  Creates an empty or prefilled List

  ## Examples

    iex> TodoApp.List.new()
    %TodoApp.List{auto_id: 1, entries: %{}}

  """
  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %List{},
      &add(&2, &1)
    )
  end

  @doc """
  Adds a todo to an existing List and return the updated List

  ## Examples

    iex> TodoApp.List.new() |> TodoApp.List.add(TodoApp.Entry.new(~D[1984-01-01], "Buy tomatoes."))
    %List{
      auto_id: 2,
      entries: %{
        1 => %Entry{
          completed: false,
          date: ~D[1984-01-01],
          id: 1,
          title: "Buy tomatoes."
        }
      }
    }

  """
  def add(
        %List{auto_id: auto_id, entries: entries} = _,
        %Entry{} = entry
      ) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = Map.put(entries, auto_id, entry)

    %List{entries: new_entries, auto_id: auto_id + 1}
  end

  @doc """
  Get returns a list of todos from an existing list

  * get_entries/1 returns a list of todos from a todo_list
  * get_entries/2 returns a list of all todos matching an id or a date

  ## Examples
    iex> todo_list = TodoApp.List.new() |> TodoApp.List.add(TodoApp.Entry.new(~D[1984-01-01], "Buy tomatoes."))
    iex> todo_list |> List.get_entries
    [
      %TodoApp.Entry{
        completed: false,
        date: ~D[1984-01-01],
        id: 1,
        title: "Buy tomatoes."
      }
    ]

    iex> todo_list = TodoApp.List.new() |> TodoApp.List.add(TodoApp.Entry.new(~D[1984-01-01], "Buy tomatoes."))
    iex> todo_list |> List.get_entries(1)
    [
      %TodoApp.Entry{
        completed: false,
        date: ~D[1984-01-01],
        id: 1,
        title: "Buy tomatoes."
      }
    ]

    iex> todo_list = TodoApp.List.new() |> TodoApp.List.add(TodoApp.Entry.new(~D[1984-01-01], "Buy tomatoes."))
    iex> todo_list |> List.get_entries(~D[1984-01-01])
    [
      %TodoApp.Entry{
        completed: false,
        date: ~D[1984-01-01],
        id: 1,
        title: "Buy tomatoes."
      }
    ]

  """
  def get_entries(%List{entries: todos} = _) do
    Enum.map(todos, fn {_, todo} -> todo end)
  end

  def get_entries(%List{entries: todos} = _, id) when is_integer(id) do
    todos
    |> Stream.filter(fn {_, todo} -> todo.id == id end)
    |> Enum.map(fn {_, todo} -> todo end)
  end

  def get_entries(%List{entries: todos} = _, %Date{} = date) do
    todos
    |> Stream.filter(fn {_, todo} -> todo.date == date end)
    |> Enum.map(fn {_, todo} -> todo end)
  end

  def delete_entry(%List{auto_id: auto_id, entries: todos}, id) when is_integer(id) do
    new_todos = Map.delete(todos, id)
    %List{auto_id: auto_id, entries: new_todos}
  end

  def toggle_complete(%List{auto_id: auto_id, entries: todos} = list, id) when is_integer(id) do
    todo = get_entries(list, id)
    new_todos = Map.update(todos, id, todo, &TodoApp.Entry.toggle_complete(&1))

    %List{auto_id: auto_id, entries: new_todos}
  end

  def get_not_completed_count(%List{entries: todos}) do
    Enum.count(todos, fn {_key, value} -> !value.completed end)
  end

  defimpl Collectable do
    def into(original) do
      into_callback = fn
        list, {:cont, todo} -> List.add(list, todo)
        list, :done -> list
        _list, :halt -> :ok
      end

      {original, into_callback}
    end
  end
end
