defmodule Neoboard.Config do
  defmacro __using__(_) do
    quote do
      def config do
        Neoboard.Config.config!(__MODULE__)
      end
    end
  end

  def config!(module) do
    {:ok, config} = Application.fetch_env(:neoboard, module)
    config
  end
end