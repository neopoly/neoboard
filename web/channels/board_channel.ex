defmodule Neoboard.BoardChannel do
  use Phoenix.Channel
  require Logger

  def join("board:neo", _auth_msg, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def terminate(_reason, _socket) do
    send(self(), :after_leave)
    :ok
  end

  def handle_info(:after_join, socket) do
    log("client joined")
    Enum.map(Neoboard.Broadcaster.messages, fn {message, payload} ->
      push(socket, message, payload)
    end)
    {:noreply, socket}
  end

  def handle_info(:after_leave, socket) do
    log("client left")
    {:noreply, socket}
  end

  defp log(what) do
    Logger.debug "BoardChannel: #{what}"
  end
end
