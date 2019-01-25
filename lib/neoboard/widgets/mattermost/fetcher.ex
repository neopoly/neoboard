defmodule Neoboard.Widgets.Mattermost.Fetcher do
  alias Neoboard.Widgets.Mattermost.Fetcher
  alias Neoboard.Gravatar

  defstruct [:api_url, :private_token, :channel_id, :since]

  def fetch(since, private_token, config) do
    %Fetcher{
      api_url: config[:api_url],
      private_token: private_token,
      channel_id: config[:channel_id],
      since: since
    } |> fetch
  end

  defp fetch(fetcher) do
    with {:ok, raw_posts} <- fetch_posts(fetcher),
         user_ids <- extract_user_ids(raw_posts),
         {:ok, users} <- fetch_users(fetcher, user_ids),
         posts <- inject_users(raw_posts, users) do
      {:ok, posts}
    else
      other -> other
    end
  end

  defp fetch_posts(fetcher) do
    case request(fetcher, posts_url(fetcher)) do
      {:ok, data} -> {:ok, extract_posts(data["posts"], data["order"])}
      other -> other
    end
  end

  defp inject_users(raw_posts, users) do
    Enum.map(raw_posts, fn(post) ->
      Map.put(post, "user", Map.get(users, post["user_id"]))
    end)
  end

  defp extract_posts(nil, _), do: []
  defp extract_posts(posts, order) do
    order
    |> Enum.map(&(Map.get(posts, &1)))
    |> Enum.filter(&(&1["delete_at"] == 0))
    |> Enum.sort(&(&1["create_at"] > &2["create_at"]))
  end

  def extract_user_ids(posts) do
    Enum.map(posts, &(&1["user_id"]))
  end

  defp extract_users(nil), do: %{}
  defp extract_users(users) do
    Enum.reduce(users, %{}, fn(user, acc) ->
      Map.put(acc, user["id"], Map.put(user, "avatar_url", avatar_url(user)))
    end)
  end

  defp fetch_users(_, []), do: {:ok, %{}}
  defp fetch_users(fetcher, user_ids) do
    case request(fetcher, users_url(fetcher), user_ids) do
      {:ok, data} -> {:ok, extract_users(data)}
      other -> other
    end
  end

  defp request(fetcher, url) do
    {:ok, response} = HTTPoison.get(url, headers(fetcher))
    parse_response(response)
  end
  defp request(fetcher, url, data) do
    {:ok, response} = HTTPoison.post(url, dump_request(data), headers(fetcher))
    parse_response(response)
  end

  defp dump_request(data) do
    Jason.encode!(data)
  end

  defp parse_response(%HTTPoison.Response{status_code: 200, body: body}) do
    Jason.decode(body)
  end
  defp parse_response(%HTTPoison.Response{status_code: 401, body: body}) do
    case Jason.decode(body) do
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

  defp posts_url(fetcher = %Fetcher{channel_id: channel, since: since}) do
    timestamp = to_timestamp(since)
    fetcher |> url("channels/#{channel}/posts?since=#{timestamp}")
  end

  defp users_url(fetcher) do
    fetcher |> url("users/ids")
  end

  defp avatar_url(user) do
    Gravatar.url(user["email"])
  end

  defp url(%Fetcher{api_url: url}, path) do
    "#{url}/#{path}"
  end

  defp to_timestamp(since) do
    DateTime.to_unix(since, :millisecond)
  end
end
