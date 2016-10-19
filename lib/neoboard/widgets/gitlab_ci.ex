defmodule Neoboard.Widgets.GitlabCi do
  use GenServer
  use Neoboard.Pusher
  use Neoboard.Config

  alias Neoboard.Widgets.GitlabCi.Fetcher

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, [])
    send(pid, :tick)
    :timer.send_interval(config[:every], pid, :tick)
    {:ok, pid}
  end

  def handle_info(:tick, _) do
    {:ok, projects} = Fetcher.fetch_projects(config[:api_url], config[:private_token])
    response = projects |> only_failed |> build_response
    push! response
    {:noreply, nil}
  end

  defp build_response(failed_projects) do
    %{failed_jobs: failed_projects}
  end

  defp only_failed(projects) do
    projects |> Enum.filter(&(&1.failed?))
  end
end
