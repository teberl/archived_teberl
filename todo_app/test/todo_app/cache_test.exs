defmodule TodoApp.CacheTest do
  use ExUnit.Case

  alias TodoApp.{System, Cache, Server, Entry, Database}

  doctest Cache

  setup do
    on_exit(fn ->
      IO.puts("Clean up file_storage for Process: #{inspect(self())}")
      Database.remove("toms_test_list")
      Database.remove("meisis_test_list")
    end)
  end

  test "server_process creates different processes" do
    toms_list = Cache.server_process("toms_test_list")
    meisis_list = Cache.server_process("meisis_test_list")

    assert toms_list != meisis_list
  end

  test "todo operations" do
    toms_list = Cache.server_process("toms_test_list")
    meisis_list = Cache.server_process("meisis_test_list")
    toms_todo = Entry.new(~D[2018-12-23], "Buy presents!")
    meisis_todo = Entry.new(~D[2018-12-24], "Eat candy!")

    Server.put(toms_list, toms_todo)
    Server.put(meisis_list, meisis_todo)

    assert [%Entry{completed: false, date: ~D[2018-12-23], title: "Buy presents!", id: 1}] ==
             Server.get(toms_list)

    assert [%Entry{completed: false, date: ~D[2018-12-24], title: "Eat candy!", id: 1}] ==
             Server.get(meisis_list)

    Server.put(toms_list, meisis_todo)

    assert [
             %Entry{completed: false, date: ~D[2018-12-23], title: "Buy presents!", id: 1},
             %Entry{completed: false, date: ~D[2018-12-24], title: "Eat candy!", id: 2}
           ] == Server.get(toms_list)

    assert [%Entry{completed: false, date: ~D[2018-12-24], title: "Eat candy!", id: 1}] ==
             Server.get(meisis_list)
  end
end
