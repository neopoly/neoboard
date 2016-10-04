defmodule Neoboard.Widgets.NichtLustig do
  use GenServer
  use Neoboard.Pusher
  use Neoboard.Config

  @image_pattern ~r{href=".*?(\d+)\.jpg"}i

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, [])
    send(pid, :tick)
    :timer.send_interval(config[:every], pid, :tick)
    {:ok, pid}
  end

  def init(_) do
    :rand.seed(:exsplus, :os.timestamp)
    {:ok, nil}
  end

  def handle_info(:tick, _) do
    {:ok, reponse} = fetch
    push! reponse
    {:noreply, nil}
  end

  defp fetch do
    HTTPoison.start
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.get(config[:url])
    response = process_body(body) |> build_response
    {:ok, response}
  end

  defp process_body(body) do
    body
    |> extract_images
    |> List.flatten
    |> Enum.shuffle
    |> List.first
    |> build_url
  end

  defp extract_images(body) do
    Regex.scan(@image_pattern, body, capture: :all_but_first)
  end

  defp build_url(image) do
    :io_lib.format(config[:base], [image])
    |> List.to_string
  end

  defp build_response(image) do
    %{image: image}
  end
end
