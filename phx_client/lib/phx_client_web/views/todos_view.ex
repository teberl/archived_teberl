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

  def filter_path(filter) do
    case filter do
      :SHOW_ALL -> Routes.todos_path(PhxClientWeb.Endpoint, :index)
      :SHOW_ACTIVE -> Routes.todos_path(PhxClientWeb.Endpoint, :active)
      :SHOW_COMPLETED -> Routes.todos_path(PhxClientWeb.Endpoint, :completed)
    end
  end
end
