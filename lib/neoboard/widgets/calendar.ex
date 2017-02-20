defmodule Neoboard.Widgets.Calendar do
  alias Neoboard.Widgets.Calendar.Parser
  alias Neoboard.Widgets.Calendar.Event
  alias Neoboard.TimeService
  use GenServer
  use Neoboard.Pusher
  use Neoboard.Config

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, nil)
    send(pid, :tick)
    :timer.send_interval(config()[:every], pid, :tick)
    {:ok, pid}
  end

  def handle_info(:tick, _) do
    {:ok, response} = fetch()
    push! response
    {:noreply, nil}
  end

  defp fetch do
    case HTTPoison.get(config()[:url]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        process_body(body)
    end
  end

  defp process_body(body) do
    data = Parser.deserialize(body)
    events = Enum.map(data.events, &Event.to_export/1)
    {:ok, %{events: events, current: TimeService.now_as_iso}}
  end
end
