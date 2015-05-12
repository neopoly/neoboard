defmodule Neoboard.Router do
  use Neoboard.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Neoboard do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  socket "/ws", Neoboard do
    channel "board:*", BoardChannel
  end

  # Other scopes may use custom stacks.
  # scope "/api", Neoboard do
  #   pipe_through :api
  # end
end
