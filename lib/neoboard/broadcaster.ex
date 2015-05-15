defmodule Neoboard.Broadcaster do
  require Logger
  @topic "board:neo"

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
    with_timestamp = add_timestamp!(payload)
    Logger.debug("[#{@topic}] #{message} -> #{Poison.encode!(with_timestamp)}")
    Neoboard.Endpoint.broadcast!(@topic, message, with_timestamp)
  end

  def module_to_message(module) do
    namespace = Atom.to_string(module)
    |> String.split(".")
    |> List.last
    |> String.downcase
    namespace <> ":state"
  end

  defp add_timestamp!(payload) do
    now = Neoboard.TimeService.now_as_iso
    Dict.put(payload, :updated_at, now)
  end
end