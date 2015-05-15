defmodule Neoboard.Widgets.Time do
  use GenServer
  use Neoboard.Broadcaster

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, [])
    send(pid, :tick)
    :timer.send_interval(1000, pid, :tick)
    {:ok, pid}
  end

  def init([]) do
    {:ok, []}
  end

  def handle_info(:tick, _) do
    now = Neoboard.TimeService.now_as_iso
    broadcast! %{now: now}
    {:noreply, now}
  end
end