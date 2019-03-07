defmodule TodoApp.ListTest do
  use ExUnit.Case
  alias TodoApp.{List, Entry}

  doctest List

  @todo_one %Entry{
    completed: false,
    date: ~D[1984-01-01],
    id: 1,
    title: "Buy tomatoes."
  }

  @todo_two %Entry{
    completed: false,
    date: ~D[1984-01-01],
    id: 2,
    title: "Buy cucumbers."
  }

  test "new/0 creates an empty %List{}" do
    assert List.new() == %List{auto_id: 1, entries: %{}}
  end

  test "new/1 creates a %List{} with the %Entry{}'s from the list'" do
    expected_result = %List{
      auto_id: 3,
      entries: %{
        1 => @todo_one,
        2 => @todo_two
      }
    }

    assert List.new([@todo_one, @todo_two]) == expected_result
  end

  test "add/2 adds a %Entry{} to an existing %List{}" do
    expected_result = %List{
      auto_id: 3,
      entries: %{
        1 => %Entry{
          completed: false,
          date: ~D[1984-01-01],
          id: 1,
          title: "Buy tomatoes."
        },
        2 => %Entry{
          completed: false,
          date: ~D[1984-01-01],
          id: 2,
          title: "Buy cucumbers."
        }
      }
    }

    assert List.new()
           |> List.add(Entry.new(~D[1984-01-01], "Buy tomatoes."))
           |> List.add(Entry.new(~D[1984-01-01], "Buy cucumbers.")) == expected_result
  end

  test "Enum.into/2 adds the %Entry{}'s to the %List{}" do
    todos = [
      Entry.new(~D[1984-01-01], "Buy fish."),
      Entry.new(~D[1984-01-01], "Buy chips."),
      Entry.new(~D[1984-01-01], "Buy beer.")
    ]

    expected_result = %List{
      auto_id: 4,
      entries: %{
        1 => %Entry{
          completed: false,
          date: ~D[1984-01-01],
          id: 1,
          title: "Buy fish."
        },
        2 => %Entry{
          completed: false,
          date: ~D[1984-01-01],
          id: 2,
          title: "Buy chips."
        },
        3 => %Entry{
          completed: false,
          date: ~D[1984-01-01],
          id: 3,
          title: "Buy beer."
        }
      }
    }

    assert Enum.into(todos, List.new()) == expected_result
  end

  test "List.delete/2 deletes the corresponding %Entry{} from the %List{}" do
    todos = [
      Entry.new(~D[1984-01-01], "Buy fish."),
      Entry.new(~D[1984-01-01], "Buy chips."),
      Entry.new(~D[1984-01-01], "Buy beer.")
    ]

    expected_result = %List{
      auto_id: 4,
      entries: %{
        1 => %Entry{
          completed: false,
          date: ~D[1984-01-01],
          id: 1,
          title: "Buy fish."
        },
        3 => %Entry{
          completed: false,
          date: ~D[1984-01-01],
          id: 3,
          title: "Buy beer."
        }
      }
    }

    assert List.new(todos)
           |> List.delete_entry(2) == expected_result
  end
end
