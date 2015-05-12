defmodule Neoboard.PageController do
  use Neoboard.Web, :controller

  plug :action

  def index(conn, _params) do
    render conn, "index.html"
  end
end
