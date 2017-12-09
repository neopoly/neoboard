defmodule Neoboard.Widgets.Calendar.DateTimeHelperTest do
  use ExUnit.Case, async: true
  alias Neoboard.Widgets.Calendar.DateTimeHelper

  test "parses dates" do
    input = "20170210"
    got   = DateTimeHelper.parse(input, %{"VALUE" => "DATE"}, nil)
    assert ~D[2017-02-10] == got
  end

  test "uses tzid from params and converts to UTC" do
    input = "20170218T120000"
    got   = DateTimeHelper.parse(input, %{"TZID" => "Europe/Berlin"}, nil)
    {:ok, expected, _} = DateTime.from_iso8601("2017-02-18T11:00:00+00:00")
    assert expected == got
  end

  test "uses tzid from fallback and converts to UTC" do
    input = "20170218T120000"
    got   = DateTimeHelper.parse(input, nil, "Europe/Berlin")
    {:ok, expected, _} = DateTime.from_iso8601("2017-02-18T11:00:00+00:00")
    assert expected == got
  end
end
