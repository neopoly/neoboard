defmodule Neoboard.Widgets.Time do
  use GenServer
  use Neoboard.Broadcaster
  use Neoboard.Config

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, [])
    send(pid, :tick)
    :timer.send_interval(config[:every], pid, :tick)
    {:ok, pid}
  end

  def handle_info(:tick, _) do
    now = Neoboard.TimeService.now_as_iso
    broadcast! %{now: now}
    {:noreply, nil}
  end
end