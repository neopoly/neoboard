defmodule Neoboard.Widgets.MattermostAuthenticationTest do
  use ExUnit.Case, async: true
  alias Neoboard.Widgets.Mattermost.Authentication

  setup do
    bypass = Bypass.open
    {:ok, bypass: bypass}
  end

  @config %{
    login_id: "the_login_id",
    password: "the_password"
  }

  @private_token "the_private_token"

  test "fetches private token", %{bypass: bypass} do
    config = build_config(bypass)

    login = "/users/login"
    Bypass.expect bypass, "POST", login, fn conn ->
      expected = ~s({"password":"the_password","login_id":"the_login_id"})
      assert {:ok, ^expected, conn} = Plug.Conn.read_body(conn)
      conn
      |> Plug.Conn.put_resp_header("Token", @private_token)
      |> send_json(%{})
    end

    assert {:ok, auth} = Authentication.login(config)
    assert @private_token, auth.private_token
  end

  defp build_config(bypass) do
    Map.merge(@config, %{
      api_url: endpoint_url(bypass)
    })
  end

  defp send_json(conn, value) do
    json = Poison.encode!(value)
    Plug.Conn.resp(conn, 200, json)
  end

  defp endpoint_url(bypass) do
    "http://localhost:#{bypass.port}"
  end
end
