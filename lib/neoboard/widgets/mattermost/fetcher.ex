defmodule Neoboard.Widgets.Mattermost.Fetcher do
  alias Neoboard.Widgets.Mattermost.Fetcher
  alias Neoboard.Gravatar

  defstruct [:api_url, :private_token, :channel_id, :team_id, :since]

  @users_per_page 1000

  def users_per_page do
    @users_per_page
  end

  def fetch(since, private_token, config) do
    %Fetcher{
      api_url: config[:api_url],
      private_token: private_token,
      team_id: config[:team_id],
      channel_id: config[:channel_id],
      since: since
    } |> fetch
  end

  defp fetch(fetcher) do
    with {:ok, raw_posts} <- fetch_posts(fetcher),
         {:ok, users} <- fetch_users(fetcher),
         posts <- inject_users(raw_posts, users) do
      {:ok, posts}
    else
      other -> other
    end
  end

  defp fetch_posts(fetcher) do
    case request(fetcher, posts_url(fetcher)) do
      {:ok, data} -> {:ok, extract_posts(data["posts"])}
      other -> other
    end
  end

  defp inject_users(raw_posts, users) do
    Enum.map(raw_posts, fn(post) ->
      Map.put(post, "user", Map.get(users, post["user_id"]))
    end)
  end

  defp extract_posts(nil), do: []
  defp extract_posts(posts) do
    posts
    |> Map.values
    |> Enum.filter(&(&1["delete_at"] == 0))
    |> Enum.sort(&(&1["create_at"] > &2["create_at"]))
  end

  defp extract_users(nil), do: %{}
  defp extract_users(users) do
    Enum.reduce(users, %{}, fn({id, user}, acc) ->
      Map.put(acc, id, Map.put(user, "avatar_url", avatar_url(user)))
    end)
  end

  defp fetch_users(fetcher), do: fetch_users(fetcher, 0, %{})
  defp fetch_users(fetcher, page, pool) do
    case request(fetcher, users_url(fetcher, page, @users_per_page)) do
      {:ok, data} ->
        users = extract_users(data)
        pool  = Map.merge(pool, users)
        if map_size(users) >= @users_per_page do
          fetch_users(fetcher, page+1, pool)
        else
          {:ok, pool}
        end
      other -> other
    end
  end

  defp request(fetcher, url) do
    {:ok, response} = HTTPoison.get(url, headers(fetcher))
    parse_response(response)
  end

  defp parse_response(%HTTPoison.Response{status_code: 200, body: body}) do
    Poison.decode(body)
  end

  defp parse_response(%HTTPoison.Response{status_code: 401, body: body}) do
    case Poison.decode(body) do
      {:ok, data} -> {:authentication_failure, data["message"]}
      other -> other
    end
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

  defp users_url(fetcher = %Fetcher{team_id: team}, page, per_page) do
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
