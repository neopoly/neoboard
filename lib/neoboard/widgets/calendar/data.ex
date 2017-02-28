defmodule Neoboard.Widgets.Calendar.Data do
  alias Neoboard.Widgets.Calendar.Data
  alias Neoboard.Widgets.Calendar.Event

  defstruct url: nil, title: nil, color: "#CCCCCC", events: [], tzid: "Etc/UTC"

  def to_export(%Data{} = data) do
    Map.put(data, :events, Enum.map(data.events, &Event.to_export/1))
  end
end
