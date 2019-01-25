defmodule Neoboard.Widgets.GitlabCi do
  use GenServer
  use Neoboard.Pusher
  use Neoboard.Config

  alias Neoboard.Widgets.GitlabCi.Fetcher

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
    url      = config()[:api_url]
    token    = config()[:private_token]
    per_page = config()[:per_page]
    timeout  = config()[:timeout]
    {:ok, projects} = Fetcher.fetch_projects(url, token, per_page, timeout)
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
