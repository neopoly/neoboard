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
    send(self(), :tick)
    {:noreply, %{
      private_token: config()[:personal_access_token],
      posts: [],
      initial_since: build_since(),
      last_post_id: nil
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
    since         = state[:initial_since]
    post_id       = state[:last_post_id]
    private_token = state[:private_token]
    posts         = state[:posts]

    case Fetcher.fetch(since, post_id, private_token, config()) do
      {:ok, new_posts} ->
        posts = new_posts ++ posts |> Enum.take(config()[:posts])
        push_posts! posts

        {:ok, Map.merge(state, %{
          posts: posts,
          since: build_since(),
          last_post_id: extract_last_post_id(posts)
        })}
      other -> other
    end
  end

  defp build_since do
    offset = Keyword.get(config(), :offset, days: -7)
    Timex.shift(TimeService.now, offset)
  end

  defp extract_last_post_id([]), do: nil
  defp extract_last_post_id([post | _]) do
    post["id"]
  end

  defp push_posts!(posts) do
    push! %{posts: posts, title: config()[:title]}
  end
end
