defmodule Neoboard.Widgets.Youtube do
  use GenServer
  use Neoboard.Pusher
  use Neoboard.Config

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, [])
    send(pid, :tick)
    {:ok, pid}
  end

  def init(_) do
    :rand.seed(:exsplus, :os.timestamp)
    {:ok, nil}
  end

  def handle_info(:tick, _) do
    push! %{url: config()[:url]}
    {:noreply, nil}
  end
end
