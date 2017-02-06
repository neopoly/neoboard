defmodule Neoboard.Widgets.Mattermost.Fetcher do
  alias Neoboard.Widgets.Mattermost.Fetcher
  alias Neoboard.Gravatar

  defstruct [:api_url, :private_token, :channel_id, :team_id, :since, :posts, :users]

  def fetch(since, config) do
    %Fetcher{
      api_url: config[:api_url],
      private_token: config[:private_token],
      team_id: config[:team_id],
      channel_id: config[:channel_id],
      since: since,
      posts: [],
      users: %{}
    } |> fetch
  end

  defp fetch(fetcher) do
    fetcher = fetcher
    |> fetch_posts
    |> fetch_users
    |> inject_users

    {:ok, fetcher.posts}
  end

  defp fetch_posts(fetcher) do
    posts = fetcher
    |> request(posts_url(fetcher))
    |> Dict.get("posts")
    |> extract_posts

    %{fetcher | posts: posts}
  end

  defp fetch_users(fetcher) do
    users = fetcher
    |> request(users_url(fetcher))
    |> extract_users

    %{fetcher | users: users}
  end

  defp inject_users(fetcher) do
    posts = Enum.map(fetcher.posts, fn(post) ->
      Dict.put(post, "user", Dict.get(fetcher.users, post["user_id"]))
    end)

    %{fetcher | posts: posts}
  end

  defp extract_posts(nil), do: []
  defp extract_posts(posts) do
    posts
    |> Dict.values
    |> Enum.filter(&(&1["delete_at"] == 0))
    |> Enum.sort(&(&1["create_at"] > &2["create_at"]))
  end

  defp extract_users(nil), do: %{}
  defp extract_users(users) do
    Enum.reduce(users, %{}, fn({id, user}, acc) ->
      Dict.put(acc, id, Dict.put(user, "avatar_url", avatar_url(user)))
    end)
  end

  defp request(fetcher, url) do
    result = HTTPoison.get(url, headers(fetcher))
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = result
    body |> Poison.decode!
  end

  defp headers(%Fetcher{private_token: token}) do
    %{
      "Authorization" => "Bearer #{token}",
      "Accept" => "application/json"
    }
  end

  defp posts_url(fetcher = %Fetcher{team_id: team, channel_id: channel, since: since}) do
    timestamp = to_timestamp(since)
    fetcher |> url("teams/#{team}/channels/#{channel}/posts/since/#{timestamp}")
  end

  defp users_url(fetcher = %Fetcher{team_id: team}) do
    # Fetch the first 100_000 users. (Won't work for larger teams.)
    page     = 0
    per_page = 100_000
    fetcher |> url("teams/#{team}/users/#{page}/#{per_page}")
  end

  defp avatar_url(user) do
    Gravatar.url(user["email"])
  end

  defp url(%Fetcher{api_url: url}, path) do
    "#{url}/#{path}"
  end

  defp to_timestamp(since) do
    DateTime.to_unix(since)
  end
end
