defmodule Neoboard.Widgets.Jenkins do
  use GenServer
  use Neoboard.Broadcaster

  @endpoint "http://ci.neopoly.de/api/json"
  @every 10000
  @failed_color "red"

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, [])
    send(pid, :tick)
    :timer.send_interval(@every, pid, :tick)
    {:ok, pid}
  end

  def handle_info(:tick, _) do
    {:ok, reponse} = fetch
    broadcast! reponse
    {:noreply, nil}
  end

  defp fetch do
    HTTPoison.start
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.get(@endpoint)
    response = process_body(body) |> build_response
    {:ok, response}
  end

  defp process_body(body) do
    body
    |> Poison.decode!
    |> extract_failed_jobs!
  end

  defp build_response(failed_jobs) do
    %{failed_jobs: failed_jobs}
  end

  defp extract_failed_jobs!(%{"jobs" => jobs}) do
    jobs
    |> Enum.filter(fn(j) -> j["color"] == @failed_color end)
  end
end