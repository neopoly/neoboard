defmodule Neoboard.Widget.Time.TimeWidget do
  use Timex
  use GenServer
  require Logger

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, [])
    :timer.send_interval(1000, pid, :tick)
    {:ok, pid}
  end

  def init([]) do
    log "init"
    {:ok, []}
  end

  def handle_info(:tick, time) do
    now = format_datetime(Date.now())
    log "tick: " <> now
    Neoboard.Sockets.broadcast("time:state", %{now: now})
    {:noreply, now}
  end

  defp log(what) do
    Logger.debug "TimeWidget: #{what}"
  end

  defp format_datetime(datetime) do
    DateFormat.format!(datetime, "{ISO}")
  end
end