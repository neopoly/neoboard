defmodule Neoboard.Widgets.Time do
  use GenServer
  use Neoboard.Pusher
  use Neoboard.Config

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, [])
    send(pid, :tick)
    :timer.send_interval(config()[:every], pid, :tick)
    {:ok, pid}
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def handle_info(:tick, _) do
    now = Neoboard.TimeService.now_as_iso()
    push! %{now: now}
    {:noreply, nil}
  end
end
