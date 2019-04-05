defmodule PhxClientWeb.HeartbeatChannel do
  use PhxClientWeb, :channel

  def join("heartbeat:listen", _payload, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    send(self(), {:beat, 0})
    {:noreply, socket}
  end

  def handle_info({:beat, i}, socket) do
    push(socket, "beat", %{body: i})
    Process.send_after(self(), {:beat, i + 1}, 1_000)
    {:noreply, socket}
  end
end
