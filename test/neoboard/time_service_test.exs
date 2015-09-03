defmodule Neoboard.TimeServiceTest do
  use ExUnit.Case, async: true

  test "it determines now" do
    assert %Timex.DateTime{} = Neoboard.TimeService.now
  end

  test "it returns now formatted" do
    formatted = Neoboard.TimeService.now("{RFC1123}")
    assert formatted =~ ~r/\w{3}, \d{1,2} \w{3} \d{4} \d{2}:\d{2}:\d{2} \+\w{4}/
  end

  test "it returns now as iso" do
    formatted = Neoboard.TimeService.now_as_iso
    assert formatted =~ ~r/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.?\d*\+\d{4}/
  end
end
