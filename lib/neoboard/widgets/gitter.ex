defmodule Neoboard.Widgets.Gitter do
  use GenServer
  use Neoboard.Pusher
  use Neoboard.Config

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, :ok)
    send(pid, :tick)
    :timer.send_interval(config[:every], pid, :tick)
    {:ok, pid}
  end

  def handle_info(:tick, _) do
    push! %{messages: fetch, title: config[:title]}
    {:noreply, nil}
  end

  defp fetch do
    HTTPoison.start
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.get(url, header)
    body |> Poison.decode!
  end

  defp header do
    %{
      "Authorization" => "Bearer #{config[:token]}",
      "Accept" => "application/json"
    }
  end

  def url(host \\ "api.gitter.im") do
    "https://#{host}/v1/rooms/#{config[:room]}/chatMessages?limit=#{config[:messages]}"
  end
end