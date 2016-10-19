defmodule Neoboard.Pusher do
  defmacro __using__(_) do
    quote do
      def push!(message, payload) do
        Neoboard.Pusher.push!(message, payload)
      end

      def push!(payload) do
        Neoboard.Pusher.module_to_message(__MODULE__)
        |> push!(payload)
      end
    end
  end

  def push!(message, payload) do
    Neoboard.Broadcaster.broadcast!(message, add_timestamp!(payload))
  end

  def module_to_message(module) do
    namespace = Atom.to_string(module)
    |> String.split(".")
    |> List.last
    |> Macro.underscore
    namespace <> ":state"
  end

  defp add_timestamp!(payload) do
    now = Neoboard.TimeService.now_as_iso
    Dict.put(payload, :updated_at, now)
  end
end
