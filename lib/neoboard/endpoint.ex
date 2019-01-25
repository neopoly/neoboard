defmodule Neoboard.Endpoint do
  use Phoenix.Endpoint, otp_app: :neoboard

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :neoboard, gzip: false,
    only: ~w(css images js favicon.ico robots.txt)

  socket "/ws", Neoboard.UserSocket,
    websocket: [check_origin: false],
    longpoll: []

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_neoboard_key",
    signing_salt: "2Z5ZsLKm"

  plug Neoboard.Router
end
