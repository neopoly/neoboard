defmodule Neoboard.PageController do
  use Neoboard.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
