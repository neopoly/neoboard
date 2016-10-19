defmodule Neoboard.Widgets.GitlabCiFetcherTest do
  use ExUnit.Case, async: true
  alias Neoboard.Widgets.GitlabCi.Fetcher
  alias Neoboard.Widgets.GitlabCi.Fetcher.Project

  setup do
    bypass = Bypass.open
    {:ok, bypass: bypass}
  end

  @private_token "verysecret"

  test "w/o projects returns no projects", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      conn = Plug.Conn.fetch_query_params(conn)
      assert_private_token(conn)
      assert "GET" == conn.method
      assert "/projects/all" == conn.request_path
      assert %{"per_page" => "100"} == conn.params

      send_json(conn, [])
    end

    assert {:ok, []} = Fetcher.fetch_projects(endpoint_url(bypass), @private_token)
  end

  test "with projects w/o builds_enabled returns no projects", %{bypass: bypass} do
    Bypass.expect bypass, "GET", "/projects/all", fn conn ->
      conn = Plug.Conn.fetch_query_params(conn)
      assert_private_token(conn)
      assert "GET" == conn.method
      assert "/projects/all" == conn.request_path
      assert %{"per_page" => "100"} == conn.params

      send_json(conn, [project(%{"builds_enabled": false})])
    end

    assert {:ok, []} = Fetcher.fetch_projects(endpoint_url(bypass), @private_token)
  end

  # TODO test "paginate projects"

  test "with green projects has no projects", %{bypass: bypass} do
    Bypass.expect bypass, "GET", "/projects/all", fn conn ->
      conn = Plug.Conn.fetch_query_params(conn)
      assert_private_token(conn)
      assert %{"per_page" => "100"} == conn.params

      send_json(conn, [project(%{"builds_enabled" => true})])
    end

    Bypass.expect bypass, "GET", "/projects/1/builds", fn conn ->
      conn = Plug.Conn.fetch_query_params(conn)
      assert_private_token(conn)
      assert %{"per_page" => "1"} == conn.params

      send_json(conn, [build(%{"status" => "success"})])
    end

    assert {:ok, [%Project{failed?: false}]} = Fetcher.fetch_projects(endpoint_url(bypass), @private_token)
  end

  test "has 3 projects has", %{bypass: bypass} do
    Bypass.expect bypass, "GET", "/projects/all", fn conn ->
      conn = Plug.Conn.fetch_query_params(conn)
      assert_private_token(conn)
      assert %{"per_page" => "100"} == conn.params

      send_json(conn, [
        project(%{"id" => 1, "builds_enabled" => true}),
        project(%{"id" => 2, "builds_enabled" => true}),
        project(%{"id" => 3, "builds_enabled" => true}),
        project(%{"id" => 2, "builds_enabled" => false})
      ])
    end

    Bypass.expect bypass, "GET", "/projects/1/builds", fn conn ->
      conn = Plug.Conn.fetch_query_params(conn)
      assert_private_token(conn)
      send_json(conn, [build(%{"id" => 1001, "status" => "failed"})])
    end

    Bypass.expect bypass, "GET", "/projects/2/builds", fn conn ->
      conn = Plug.Conn.fetch_query_params(conn)
      assert_private_token(conn)
      send_json(conn, [build(%{"id" => 1002, "status" => "failed"})])
    end

    Bypass.expect bypass, "GET", "/projects/3/builds", fn conn ->
      conn = Plug.Conn.fetch_query_params(conn)
      assert_private_token(conn)
      send_json(conn, [build(%{"id" => 1003, "status" => "success"})])
    end

    assert {:ok, [
        %Project{id: 1, failed?: true, url: "http://project/builds/1001"},
        %Project{id: 2, failed?: true, url: "http://project/builds/1002"},
        %Project{id: 3, failed?: false}
      ]} = Fetcher.fetch_projects(endpoint_url(bypass), @private_token)
  end

  def assert_private_token(conn) do
    token = conn.req_headers
    |> Enum.find_value(fn {key, value} -> key == "private-token" && value end)
    assert token == @private_token
  end

  defp endpoint_url(bypass) do
    "http://localhost:#{bypass.port}"
  end

  defp send_json(conn, value) do
    json = Poison.encode!(value)
    Plug.Conn.resp(conn, 200, json)
  end

  defp project(map) do
    %{"id": 1, "name": "project", "web_url": "http://project", "builds_enabled": true}
    |> Map.merge(map)
  end

  defp build(map) do
    %{"id": 1000, "status": "success"}
    |> Map.merge(map)
  end
end
