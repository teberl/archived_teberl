defmodule PhxClientWeb.TodosView do
  use Phoenix.LiveView
  use PhxClientWeb, :view

  def filter_title(filter) do
    case filter do
      :SHOW_ALL -> "All"
      :SHOW_ACTIVE -> "Active"
      :SHOW_COMPLETED -> "Completed"
    end
  end

  def todo_count_text(active_count) do
    items_text = if active_count == 1, do: "item", else: "items"

    if active_count == 0,
      do: "<strong>No</strong> #{items_text}",
      else: "<strong>#{active_count}</strong> #{items_text}"
  end

  def filter_path(filter, list_id) do
    filter_query = case filter do
      :SHOW_ALL -> "all"
      :SHOW_ACTIVE -> "active"
      :SHOW_COMPLETED -> "completed"
      _ -> "all"
    end

    Routes.todos_url(PhxClientWeb.Endpoint, :todo_list, list_id, filter: filter_query)
  end
end
