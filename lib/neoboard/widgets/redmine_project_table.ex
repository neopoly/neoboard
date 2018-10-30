defmodule Neoboard.Widgets.RedmineProjectTable do
  use GenServer
  use Neoboard.Pusher
  use Neoboard.Config
  alias Neoboard.TimeService

  def init(args) do
    {:ok, args}
  end

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, nil)
    send(pid, :tick)
    :timer.send_interval(config()[:every], pid, :tick)
    {:ok, pid}
  end

  def handle_info(:tick, _) do
    push! build_response()
    {:noreply, nil}
  end

  defp build_response do
    url = :io_lib.format(config()[:url], url_options()) |> List.to_string
    %{url: url, title: config()[:title]}
  end

  defp url_options do
    now = TimeService.now
    cache_key = DateTime.to_unix(now)
    [
      Integer.to_string(now.month),
      Integer.to_string(now.year),
      Integer.to_string(cache_key)
    ]
  end
end
