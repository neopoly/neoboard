defmodule Neoboard.PageControllerTest do
  use Neoboard.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    assert html_response(conn, 200) =~ "Loading dashboard..."
  end
end
