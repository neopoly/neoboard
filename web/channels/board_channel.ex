defmodule Neoboard.BoardChannel do
  use Phoenix.Channel
  require Logger

  def join("board:neo", _auth_msg, socket) do
    send(self, :after_join)
    {:ok, socket}
  end

  def terminate({trigger, reason}, socket) do
    log("#{trigger} -> #{reason}")
    send(self, :after_leave)
    :ok
  end

  def handle_info(:after_join, socket) do
    log("client joined")
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