defmodule PhxClientWeb.ClockLive do
  use Phoenix.LiveView

  import Calendar.Strftime

  def render(assigns) do
    ~L"""
    <p class="lead">
      <h2><%= strftime!(@date, "%A %Y-%m-%e %H:%M:%S") %></h2>
      <h2>The current time in unix_ms</h2>
      <div>(udates every 10ms from the server)</div>
      <span><%= @ms %></span>
    </p>
    """
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(10, self(), :tick)

    {:ok, set_date(socket)}
  end

  def handle_info(:tick, socket) do
    {:noreply, set_date(socket)}
  end

  defp set_date(socket) do
    in_ms = DateTime.utc_now() |> DateTime.to_unix(:millisecond)
    assign(socket, %{date: :calendar.local_time(), ms: in_ms})
  end
end
