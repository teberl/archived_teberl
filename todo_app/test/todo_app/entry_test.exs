defmodule TodoApp.EntryTest do
  use ExUnit.Case
  alias TodoApp.Entry

  doctest Entry

  test "new/2 creates a %Entry{}" do
    assert Entry.new(~D[1984-01-01], "Buy tomatoes.") == %Entry{
             completed: false,
             date: ~D[1984-01-01],
             id: nil,
             title: "Buy tomatoes."
           }
  end

  test "new/2 raises an error for invalid or missing arguments" do
    assert_raise UndefinedFunctionError, fn -> Entry.new() end
    assert_raise FunctionClauseError, fn -> Entry.new("1984-01-01", "Buy tomatoes.") end
    assert_raise FunctionClauseError, fn -> Entry.new(~D[1984-01-01], :tomatoes) end
  end
end
