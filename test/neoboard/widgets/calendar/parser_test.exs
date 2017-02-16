defmodule Neoboard.Widgets.Calendar.ParserTest do
  use ExUnit.Case, async: true
  alias Neoboard.Widgets.Calendar.Parser

  setup do
    {:ok, doc: load_fixture!()}
  end

  test "parses all events and timezone", %{doc: doc} do
    data = Parser.deserialize(doc)
    assert 3 == length(data.events)
    assert "Europe/Berlin" == data.tzid
  end

  test "parses 'DEMO A' event", %{doc: doc} do
    event = Enum.at(Parser.deserialize(doc).events, 0)
    assert "UID:UUUU-UUUUUUUU-1-00000001", event.id
    assert ~D[2017-02-08] == event.start
    assert ~D[2017-02-18] == event.end
    assert "Demo A" == event.title
    assert "Category A" == event.categories
  end

  test "parses 'DEMO C' event", %{doc: doc} do
    event = Enum.at(Parser.deserialize(doc).events, 2)
    assert "UID:UUUU-UUUUUUUU-1-00000003", event.id

    starts = DateTime.from_naive!(~N[2017-02-18 11:00:00], "Etc/UTC")
    assert starts == event.start
    ends = DateTime.from_naive!(~N[2017-02-18 12:00:00], "Etc/UTC")
    assert ends == event.end

    assert "Demo C" == event.title
    assert nil == event.categories
  end

  defp load_fixture! do
    Path.join(__DIR__, "calendar_fixture.ics")
    |> File.read!
  end
end
