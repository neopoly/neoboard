defmodule Neoboard.Widgets.Calendar.Parser do
  alias Neoboard.Widgets.Calendar.Data
  alias Neoboard.Widgets.Calendar.Event
  alias Neoboard.Widgets.Calendar.DateTimeHelper

  def deserialize(%Data{} = data, input) do
    input
    |> String.split("\n")
    |> Enum.map(&extract_properties/1)
    |> Enum.reject(&(&1 == nil))
    |> Enum.reduce(data, &parse/2)
    |> reverse_events
  end

  defp parse({"TZID", tzid, _}, data), do: Map.put(data, :tzid, tzid)
  defp parse({"BEGIN", "VEVENT", _}, data) do
    add_event(data)
  end
  defp parse({"UID", value, _}, data) do
    update_event(data, :id, value)
  end
  defp parse({"SUMMARY", value, _}, data) do
    update_event(data, :title, value)
  end
  defp parse({"DTSTART", value, params}, data) do
    update_event(data, :start, DateTimeHelper.parse(value, params, data.tzid))
  end
  defp parse({"DTEND", value, params}, data) do
    update_event(data, :end, DateTimeHelper.parse(value, params, data.tzid))
  end
  defp parse({"CATEGORIES", value, _}, data) do
    update_event(data, :categories, value)
  end
  defp parse({"LOCATION", value, _}, data) do
    update_event(data, :location, value)
  end
  defp parse({"DESCRIPTION", value, _}, data) do
    update_event(data, :description, value)
  end
  defp parse({"X-WR-CALNAME", value, _}, data) do
    Map.put(data, :title, value)
  end
  defp parse(_, data), do: data

  defp add_event(%{events: events} = data) do
    Map.put(data, :events, [%Event{} | events])
  end

  defp update_event(%{events: [event | rest]} = data, key, value) do
    updated_event = %{event | key => value}
    Map.put(data, :events, [updated_event | rest])
  end
  defp update_event(data, _, _), do: data

  defp extract_properties(""), do: nil
  defp extract_properties(line) do
    [key, value]  = String.split(line, ":", parts: 2, trim: true)
    {key, params} = extract_params_from_key(key)
    {key, String.trim(value), params}
  end

  defp extract_params_from_key(key) do
    {key, rest} = case String.split(key, ";", trim: true) do
      [key] -> {key, []}
      [key | rest] -> {key, rest}
    end
    params = Enum.reduce(rest, %{}, fn(param, acc) ->
      [name, value] = String.split(param, "=", parts: 2, trim: true)
      Map.put(acc, name, value)
    end)
    {key, params}
  end

  defp reverse_events(%{events: events} = data) do
    %{data | events: Enum.reverse(events)}
  end
end
