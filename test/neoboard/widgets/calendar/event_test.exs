defmodule Neoboard.Widgets.Calendar.EventTest do
  use ExUnit.Case, async: true
  alias Neoboard.Widgets.Calendar.Event

  test "isn't all_day? if a start/end is DateTime" do
    event = %Event{}
    datetime = DateTime.from_naive!(~N[2017-02-01 10:10:10], "Etc/UTC")

    assert false == Event.all_day?(event)

    event = %{event | start: datetime}
    assert false == Event.all_day?(event)

    event = %{event | end: datetime}
    assert false == Event.all_day?(event)
  end

  test "is all_day when both a start/end is Date" do
    event = %Event{
      start: ~D[2017-02-01],
      end: ~D[2017-02-01],
    }

    assert true == Event.all_day?(event)
  end

  test "to_export" do
    event = %Event{
      id: "some_id",
      title: "the title",
      start: ~D[2017-02-01],
      end: ~D[2017-02-01],
      categories: "the_categories"
    }

    expected = Map.merge(event, %{
      start: "2017-02-01T00:00:00",
      end: "2017-02-01T00:00:00",
      allDay: true
    })

    assert expected == Event.to_export(event)
  end
end
