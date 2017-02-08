defmodule Neoboard.Widgets.Images do
  use GenServer
  use Neoboard.Pusher
  use Neoboard.Config

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, :ok)
    send(pid, :tick)
    :timer.send_interval(config()[:every], pid, :tick)
    {:ok, pid}
  end

  def init(:ok) do
    {:ok, config()[:urls]}
  end

  def handle_info(:tick, [url | tail]) do
    push! %{url: url}
    {:noreply, tail ++ [url]}
  end

  def handle_info(:tick, []) do
    # nothing to do if no images exists
    {:noreply, []}
  end
end
