defmodule Neoboard.Widgets.Calendar do
  alias Neoboard.Widgets.Calendar.Parser
  alias Neoboard.Widgets.Calendar.Data
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
    events = fetch_calendars(config()[:calendars])
    |> Enum.map(fn(data) -> data.events end)
    |> List.flatten

    push! %{events: events, current: TimeService.now_as_iso}
    {:noreply, nil}
  end

  defp fetch_calendars([]), do: []
  defp fetch_calendars([configuration | rest]) do
    data = struct(Data, configuration)
    [fetch(data)] ++ fetch_calendars(rest)
  end

  defp fetch(data) do
    case HTTPoison.get(data.url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        process_body(data, body)
    end
  end

  defp process_body(data, body) do
    Parser.deserialize(data, body)
    |> Data.to_export
    |> inject_calendar_data_into_events
  end

  defp inject_calendar_data_into_events(data) do
    updated_events = Enum.map(data.events, fn(event) ->
      Map.merge(event, %{color: data.color, calendar: data.title})
    end)
    Map.put(data, :events, updated_events)
  end
end
