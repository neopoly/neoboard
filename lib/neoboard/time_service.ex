defmodule Neoboard.TimeService do
  use Timex

  def now do
    DateTime.now
  end

  def now(format) do
    Timex.format!(now, format)
  end

  def now_as_iso do
    now("{ISO:Extended}")
  end
end
