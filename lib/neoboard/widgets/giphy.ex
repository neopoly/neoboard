defmodule Neoboard.Widgets.Giphy do
  use GenServer
  use Neoboard.Pusher
  use Neoboard.Config

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, [])
    send(pid, :tick)
    :timer.send_interval(config()[:every], pid, :tick)
    {:ok, pid}
  end

  def init(_) do
    :rand.seed(:exsplus, :os.timestamp)
    {:ok, nil}
  end

  def handle_info(:tick, _) do
    {:ok, reponse} = fetch()
    push! reponse
    {:noreply, nil}
  end

  defp fetch do
    case HTTPoison.get(api_url()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        response = process_body(body) |> build_response
        {:ok, response}
    end
  end

  defp api_url do
    config()[:url]
  end

  defp process_body(body) do
    body
    |> decode
    |> extract_url
  end

  defp decode(string) do
    Jason.decode!(string)["data"]
  end

  # Handle response from Giphy `random` api endpoint
  #
  # * Random API: https://github.com/Giphy/GiphyAPI#random-endpoint
  defp extract_url(data) when is_map(data) do
    data["image_url"]
  end

  # Handle response from Giphy from `search` and `trending` api endpoint
  #
  # * Search API: https://github.com/Giphy/GiphyAPI#search-endpoint
  # * Trending API: https://github.com/Giphy/GiphyAPI#trending-gifs-endpoint
  defp extract_url(data) when is_list(data) do
    format = "downsized"
    Enum.random(data)["images"][format]["url"]
  end

  defp build_response(image) do
    %{image: image}
  end
end
