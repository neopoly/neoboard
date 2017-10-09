defmodule Neoboard.Widgets.MattermostFetcherTest do
  use ExUnit.Case, async: true
  alias Neoboard.Widgets.Mattermost.Fetcher

  setup do
    bypass = Bypass.open
    {:ok, bypass: bypass}
  end

  @config %{
    team_id: "the_team_id",
    channel_id: "the_channel_id"
  }

  @private_token "the_private_token"

  test "w/o posts and users returns no posts", %{bypass: bypass} do
    since = DateTime.from_unix!(0)
    config = build_config(bypass)

    posts = "/teams/the_team_id/channels/the_channel_id/posts/since/0"
    Bypass.expect bypass, "GET", posts, fn conn ->
      conn = Plug.Conn.fetch_query_params(conn)
      assert_private_token_header(conn)
      send_json(conn, %{})
    end

    users = "/users/0/#{Fetcher.users_per_page}"
    Bypass.expect bypass, "GET", users, fn conn ->
      conn = Plug.Conn.fetch_query_params(conn)
      assert_private_token_header(conn)
      send_json(conn, %{})
    end

    assert {:ok, []} = Fetcher.fetch(since, @private_token, config)
  end

  test "ignores deleted posts", %{bypass: bypass} do
    since = DateTime.from_unix!(0)
    config = build_config(bypass)
    posts = "/teams/the_team_id/channels/the_channel_id/posts/since/0"
    Bypass.expect bypass, "GET", posts, fn conn ->
      conn = Plug.Conn.fetch_query_params(conn)
      assert_private_token_header(conn)
      send_json(conn, %{
        "order" => ["p1"],
        "posts" => %{
          "p1" => fake_post(1476880485, "u1")
        }
      })
    end

    users = "/users/0/#{Fetcher.users_per_page}"
    Bypass.expect bypass, "GET", users, fn conn ->
      conn = Plug.Conn.fetch_query_params(conn)
      assert_request_header(conn, "authorization", "Bearer #{@private_token}")
      send_json(conn, %{
        "u1" => fake_user()
      })
    end

    assert {:ok, []} = Fetcher.fetch(since, @private_token, config)
  end

  test "injects enriched users into posts", %{bypass: bypass} do
    since = DateTime.from_unix!(0)
    config = build_config(bypass)

    posts = "/teams/the_team_id/channels/the_channel_id/posts/since/0"
    Bypass.expect bypass, "GET", posts, fn conn ->
      conn = Plug.Conn.fetch_query_params(conn)
      assert_private_token_header(conn)
      send_json(conn, %{
        "order" => ["p1"],
        "posts" => %{
          "p1" => fake_post(0, "u1")
        }
      })
    end

    users = "/users/0/#{Fetcher.users_per_page}"
    Bypass.expect bypass, "GET", users, fn conn ->
      conn = Plug.Conn.fetch_query_params(conn)
      assert_private_token_header(conn)
      send_json(conn, %{
        "u1" => fake_user()
      })
    end

    expected = [%{
      "create_at" => 1476880484,
      "delete_at" => 0,
      "id"        => "p1",
      "message"   => "Some message",
      "user_id"   => "u1",
      "user"    => %{
        "avatar_url" => "https://secure.gravatar.com/avatar/0bc83cb571cd1c50ba6f3e8a78ef1346",
        "email" => "MyEmailAddress@example.com",
        "username" => "the_username"
      }
    }]

    assert {:ok, ^expected} = Fetcher.fetch(since, @private_token, config)
  end

  test "paginates the users if needed", %{bypass: bypass} do
    since = DateTime.from_unix!(0)
    config = build_config(bypass)

    posts = "/teams/the_team_id/channels/the_channel_id/posts/since/0"
    Bypass.expect bypass, "GET", posts, fn conn ->
      conn = Plug.Conn.fetch_query_params(conn)
      assert_private_token_header(conn)
      send_json(conn, %{
        "order" => ["p1"],
        "posts" => %{
          "p1" => fake_post(0, "u15")
        }
      })
    end

    users = "/users/0/#{Fetcher.users_per_page}"
    Bypass.expect bypass, "GET", users, fn conn ->
      conn = Plug.Conn.fetch_query_params(conn)
      assert_private_token_header(conn)
      send_json(conn, fake_users(1, Fetcher.users_per_page))
    end

    users = "/users/1/#{Fetcher.users_per_page}"
    Bypass.expect bypass, "GET", users, fn conn ->
      conn = Plug.Conn.fetch_query_params(conn)
      assert_private_token_header(conn)
      send_json(conn, fake_users(Fetcher.users_per_page+1, 2*Fetcher.users_per_page-1))
    end

    expected = [%{
      "create_at" => 1476880484,
      "delete_at" => 0,
      "id"        => "p1",
      "message"   => "Some message",
      "user_id"   => "u15",
      "user"    => %{
        "avatar_url" => "https://secure.gravatar.com/avatar/0bc83cb571cd1c50ba6f3e8a78ef1346",
        "email" => "MyEmailAddress@example.com",
        "username" => "the_username"
      }
    }]

    assert {:ok, ^expected} = Fetcher.fetch(since, @private_token, config)
  end

  test "fails as authentication_failure", %{bypass: bypass} do
    since = DateTime.from_unix!(0)
    config = build_config(bypass)

    posts = "/teams/the_team_id/channels/the_channel_id/posts/since/0"
    Bypass.expect bypass, "GET", posts, fn conn ->
      send_json(conn, %{"message" => "Some auth error"}, 401)
    end

    assert {:authentication_failure, "Some auth error"} = Fetcher.fetch(since, @private_token, config)
  end

  test "fails as error if response isn't JSON", %{bypass: bypass} do
    since = DateTime.from_unix!(0)
    config = build_config(bypass)

    posts = "/teams/the_team_id/channels/the_channel_id/posts/since/0"
    Bypass.expect bypass, "GET", posts, fn conn ->
      Plug.Conn.resp(conn, 200, "INVALID")
    end

    assert {:error, _} = Fetcher.fetch(since, @private_token, config)
  end

  defp build_config(bypass) do
    Map.merge(@config, %{
      api_url: endpoint_url(bypass)
    })
  end

  defp assert_private_token_header(conn) do
    assert_request_header(conn, "authorization", "Bearer #{@private_token}")
  end

  defp assert_request_header(conn, key, value) do
    val = conn.req_headers
    |> Enum.find_value(fn {k, v} -> k == key && v end)
    assert val == value
  end

  defp send_json(conn, value) do
    send_json(conn, value, 200)
  end

  defp send_json(conn, value, status) do
    json = Poison.encode!(value)
    Plug.Conn.resp(conn, status, json)
  end

  defp endpoint_url(bypass) do
    "http://localhost:#{bypass.port}"
  end

  defp fake_users(lower_id, upper_id) do
    Enum.reduce(lower_id..upper_id, %{}, fn(x, acc) ->
      Map.put(acc, "u#{x}", fake_user())
    end)
  end

  defp fake_user do
    %{
      "username" => "the_username",
      "email" => "MyEmailAddress@example.com"
    }
  end

  defp fake_post(delete_at, user_id) do
    %{
      "id"        => "p1",
      "message"   => "Some message",
      "user_id"   => user_id,
      "delete_at" => delete_at,
      "create_at" => 1476880484
    }
  end
end
