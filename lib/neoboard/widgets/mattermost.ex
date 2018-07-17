defmodule Neoboard.Widgets.Mattermost do
  use GenServer
  use Neoboard.Pusher
  use Neoboard.Config
  alias Neoboard.TimeService
  alias Neoboard.Widgets.Mattermost.Fetcher

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, :ok)
    send(pid, :login)
    {:ok, pid}
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_info(:login, _) do
    send(self, :tick)
    {:noreply, %{
      private_token: config()[:personal_access_token],
      posts: [],
      last_fetch: initial_last_fetch()
    }}
  end

  def handle_info(:tick, state) do
    case fetch_and_push_posts(state) do
      {:ok, state} ->
        :timer.send_after(config()[:every], self(), :tick)
        {:noreply, state}
      {:authentication_failure, _} ->
        send(self(), :login)
        {:noreply, %{}}
    end
  end

  defp fetch_and_push_posts(state) do
    last_fetch    = state[:last_fetch]
    private_token = state[:private_token]
    posts         = state[:posts]

    case Fetcher.fetch(last_fetch, private_token, config()) do
      {:ok, new_posts} ->
        posts = new_posts ++ posts |> Enum.take(config()[:posts])
        push_posts! posts

        {:ok, %{
          posts: posts,
          last_fetch: TimeService.now,
          private_token: private_token
        }}
      other -> other
    end
  end

  defp initial_last_fetch do
    offset = Keyword.get(config(), :offset, days: -7)
    Timex.shift(TimeService.now, offset)
  end

  defp push_posts!(posts) do
    push! %{posts: posts, title: config()[:title]}
  end
end
