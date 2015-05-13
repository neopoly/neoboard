defmodule Neoboard.Broadcaster do
  require Logger

  defmacro __using__(_) do
    quote do
      def broadcast!(message, payload) do
        Neoboard.Broadcaster.broadcast!(message, payload)
      end

      def broadcast!(payload) do
        Neoboard.Broadcaster.module_to_message(__MODULE__)
        |> broadcast!(payload)
      end
    end
  end

  def broadcast!(message, payload) do
    Logger.debug("#{message} -> #{Poison.encode!(payload)}")
    Neoboard.Sockets.broadcast!(message, payload)
  end

  def module_to_message(module) do
    namespace = Atom.to_string(module)
    |> String.split(".")
    |> List.last
    |> String.downcase
    namespace <> ":state"
  end
end