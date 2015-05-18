defmodule Neoboard.Widgets.Notepad do
  use GenServer
  use Neoboard.Pusher
  use Neoboard.Config

  @body_pattern ~r{<body>\s*(.*)</body>}s

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, nil)
    send(pid, :tick)
    :timer.send_interval(config[:every], pid, :tick)
    {:ok, pid}
  end

  def handle_info(:tick, _) do
    {:ok, response} = fetch
    push! response
    {:noreply, nil}
  end

  defp fetch do
    HTTPoison.start
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.get(config[:url])
    response = process_body(body)
    {:ok, response}
  end

  defp process_body(body) do
    c = Regex.run(@body_pattern, body, capture: :all_but_first)
        |> List.first
    %{content: c, title: config[:title], info: config[:info]}
  end
end