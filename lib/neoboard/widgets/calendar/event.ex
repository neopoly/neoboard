defmodule Neoboard.Widgets.Calendar.Event do
  alias Timex
  alias Neoboard.Widgets.Calendar.Event

  defstruct [:id, :title, :start, :end, :categories, :location, :description]

  def all_day?(%Event{start: %Date{}, end: %Date{}}), do: true
  def all_day?(_), do: false

  def to_export(%Event{} = event) do
    event
    |> Map.merge(%{
      start: format_as_iso(event.start),
      end: format_as_iso(event.end),
      allDay: all_day?(event)
    })
  end

  defp format_as_iso(datetime) do
    Timex.format!(datetime, "{ISO:Extended}")
  end
end
