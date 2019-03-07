defmodule TodoAppTest do
  use ExUnit.Case
  doctest TodoApp

  test "greets the world" do
    assert TodoApp.hello() == :world
  end
end
