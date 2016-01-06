defmodule Neoboard.TimeService do
  use Timex

  def now do
    Date.now
  end

  def now(format) do
    DateFormat.format!(now, format)
  end

  def now_as_iso do
    now("{ISO:Extended}")
  end
end
