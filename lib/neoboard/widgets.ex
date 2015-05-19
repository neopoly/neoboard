defmodule Neoboard.Widgets do
  def enabled do
    Application.get_all_env(:neoboard)
    |> Dict.keys
    |> Enum.filter(&widget_module?/1)
  end

  defp widget_module?(mod) do
    to_string(mod) |> String.match?(~r/Neoboard\.Widgets\.\w+/)
  end
end