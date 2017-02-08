defmodule Neoboard.Widgets do
  def enabled do
    Application.get_all_env(:neoboard)
    |> Keyword.keys
    |> Enum.filter(&widget_module?/1)
  end

  def auto_start? do
    Keyword.get(config(), :auto_start, true)
  end

  defp widget_module?(mod) do
    to_string(mod) |> String.match?(~r/Neoboard\.Widgets\.\w+/)
  end

  defp config do
    Application.get_env(:neoboard, __MODULE__, Keyword.new)
  end
end
