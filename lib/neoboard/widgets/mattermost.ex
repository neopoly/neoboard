defmodule Neoboard.Widgets.Mattermost do
  use GenServer
  use Neoboard.Pusher
  use Neoboard.Config
  alias Neoboard.TimeService
  alias Neoboard.Widgets.Mattermost.Fetcher

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, :ok)
    send(pid, :tick)
    :timer.send_interval(config[:every], pid, :tick)
    {:ok, pid}
  end

  def init(:ok) do
    HTTPoison.start

    {:ok, %{
      posts: [],
      last_fetch: initial_last_fetch
    }}
  end

  def handle_info(:tick, state) do
    {:ok, new_posts} = Fetcher.fetch(state[:last_fetch], config)
    posts = new_posts ++ state[:posts] |> Enum.take(config[:posts])

    push_posts! posts

    {:noreply, %{
      posts: posts,
      last_fetch: TimeService.now
    }}
  end

  defp initial_last_fetch do
    offset = Dict.get(config, :offset, days: -7)
    Timex.shift(TimeService.now, offset)
  end

  defp push_posts!(posts) do
    push! %{posts: posts, title: config[:title]}
  end
end
