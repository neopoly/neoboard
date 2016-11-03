defmodule Neoboard.Widgets.MattermostFetcherTest do
  use ExUnit.Case, async: true
  alias Neoboard.Widgets.Mattermost.Fetcher

  setup do
    bypass = Bypass.open
    {:ok, bypass: bypass}
  end

  @config %{
    private_token: "the_private_token",
    team_id: "the_team_id",
    channel_id: "the_channel_id"
  }

  test "w/o posts and users returns no posts", %{bypass: bypass} do
    since = DateTime.from_unix!(0)
    config = build_config(bypass)

    posts = "/teams/the_team_id/channels/the_channel_id/posts/since/0"
    Bypass.expect bypass, "GET", posts, fn conn ->
      conn = Plug.Conn.fetch_query_params(conn)
      assert_request_header(conn, "authorization", "Bearer the_private_token")
      send_json(conn, %{})
    end

    users = "/users/profiles/the_team_id"
    Bypass.expect bypass, "GET", users, fn conn ->
      conn = Plug.Conn.fetch_query_params(conn)
      assert_request_header(conn, "authorization", "Bearer the_private_token")
      send_json(conn, %{})
    end

    assert {:ok, []} = Fetcher.fetch(since, config)
  end

  test "ignores deleted posts", %{bypass: bypass} do
    since = DateTime.from_unix!(0)
    config = build_config(bypass)
    posts = "/teams/the_team_id/channels/the_channel_id/posts/since/0"
    Bypass.expect bypass, "GET", posts, fn conn ->
      conn = Plug.Conn.fetch_query_params(conn)
      assert_request_header(conn, "authorization", "Bearer the_private_token")
      send_json(conn, %{
        "order" => ["p1"],
        "posts" => %{
          "p1" => %{
            "id"        => "p1",
            "message"   => "Some message",
            "user_id"   => "u1",
            "delete_at" => 1476880485,
            "create_at" => 1476880484
          }
        }
      })
    end

    users = "/users/profiles/the_team_id"
    Bypass.expect bypass, "GET", users, fn conn ->
      conn = Plug.Conn.fetch_query_params(conn)
      assert_request_header(conn, "authorization", "Bearer the_private_token")
      send_json(conn, %{
        "u1" => %{
          "username" => "the_username",
          "email" => "MyEmailAddress@example.com"
        }
      })
    end

    assert {:ok, []} = Fetcher.fetch(since, config)
  end

  test "injects enriched users into posts", %{bypass: bypass} do
    since = DateTime.from_unix!(0)
    config = build_config(bypass)

    posts = "/teams/the_team_id/channels/the_channel_id/posts/since/0"
    Bypass.expect bypass, "GET", posts, fn conn ->
      conn = Plug.Conn.fetch_query_params(conn)
      assert_request_header(conn, "authorization", "Bearer the_private_token")
      send_json(conn, %{
        "order" => ["p1"],
        "posts" => %{
          "p1" => %{
            "id"        => "p1",
            "message"   => "Some message",
            "user_id"   => "u1",
            "delete_at" => 0,
            "create_at" => 1476880484
          }
        }
      })
    end

    users = "/users/profiles/the_team_id"
    Bypass.expect bypass, "GET", users, fn conn ->
      conn = Plug.Conn.fetch_query_params(conn)
      assert_request_header(conn, "authorization", "Bearer the_private_token")
      send_json(conn, %{
        "u1" => %{
          "username" => "the_username",
          "email" => "MyEmailAddress@example.com"
        }
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

    assert {:ok, ^expected} = Fetcher.fetch(since, config)
  end

  defp build_config(bypass) do
    Dict.merge(@config, %{
      api_url: endpoint_url(bypass)
    })
  end

  def assert_request_header(conn, key, value) do
    val = conn.req_headers
    |> Enum.find_value(fn {k, v} -> k == key && v end)
    assert val == value
  end

  defp send_json(conn, value) do
    json = Poison.encode!(value)
    Plug.Conn.resp(conn, 200, json)
  end

  defp endpoint_url(bypass) do
    "http://localhost:#{bypass.port}"
  end
end
