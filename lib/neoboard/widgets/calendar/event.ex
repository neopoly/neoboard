defmodule Neoboard.Widgets.Calendar.Event do
  alias Neoboard.Widgets.Calendar.Event

  defstruct [:id, :title, :start, :end, :categories]

  def all_day?(%Event{start: %Date{}, end: %Date{}}), do: true
  def all_day?(_), do: false

  def to_export(%Event{} = event) do
    event
    |> Map.merge(%{allDay: all_day?(event)})
  end
end
