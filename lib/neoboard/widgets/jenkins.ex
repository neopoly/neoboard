defmodule Neoboard.Widgets.Jenkins do
  use GenServer
  use Neoboard.Pusher
  use Neoboard.Config

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, [])
    send(pid, :tick)
    :timer.send_interval(config()[:every], pid, :tick)
    {:ok, pid}
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def handle_info(:tick, _) do
    {:ok, reponse} = fetch()
    push! reponse
    {:noreply, nil}
  end

  defp fetch do
    case HTTPoison.get(config()[:url]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        response = process_body(body) |> build_response
        {:ok, response}
    end
  end

  defp process_body(body) do
    body
    |> Jason.decode!
    |> extract_failed_jobs!
  end

  defp build_response(failed_jobs) do
    %{failed_jobs: failed_jobs}
  end

  defp extract_failed_jobs!(%{"jobs" => jobs}) do
    jobs
    |> Enum.filter(fn(j) -> j["color"] == config()[:failed_color] end)
  end
end
