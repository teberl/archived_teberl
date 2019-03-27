defmodule PhxClientWeb.CounterLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div>
      <h1>The count is: <%= @val %></h1>
      <button phx-click="boom" class="alert-danger">BOOM</button>
      <button phx-click="dec">-</button>
      <button phx-click="inc">+</button>
    </div>
    <%=   %>
    <div style="visibility: <%= get_visibility(@val) %>;">
      <%= live_render(@socket, PhxClientWeb.ClockLive) %>
    </div>
    """
  end

  def mount(_session, socket) do
    {:ok, assign(socket, :val, 0)}
  end

  def handle_event("inc", _, socket) do
    {:noreply, update(socket, :val, &(&1 + 1))}
  end

  def handle_event("dec", _, socket) do
    IO.inspect(socket)
    {:noreply, update(socket, :val, &(&1 - 1))}
  end

  defp get_visibility(val) do
    case rem(val, 2) |> abs do
      1 -> "hidden"
      _ -> "visible"
    end
  end
end
