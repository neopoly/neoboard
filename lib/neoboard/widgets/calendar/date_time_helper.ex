defmodule Neoboard.Widgets.Calendar.DateTimeHelper do
  alias Timex.Timezone

  def parse(string, %{"VALUE" => "DATE"}, _) do
    Timex.parse!(string, "{YYYY}{0M}{0D}") |> NaiveDateTime.to_date
  end
  def parse(string, %{"TZID" => tzid}, _), do: to_datetime(string, tzid)
  def parse(string, _, nil), do: to_datetime(string, "Etc/UTC")
  def parse(string, _, tzid), do: to_datetime(string, tzid)

  defp to_datetime(string, timezone) do
    datetime = case String.last(string) do
      "Z" -> string <> timezone
      _   -> string <> "Z" <> timezone
    end

    datetime
    |> Timex.parse!("{YYYY}{0M}{0D}T{h24}{m}{s}Z{Zname}")
    |> Timezone.convert("Etc/UTC")
  end
end
