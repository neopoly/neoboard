defmodule Neoboard.Sockets do
  require Logger
  @name __MODULE__

  def start_link do
    Agent.start_link(fn -> [] end, sockets: [], name: @name)
  end

  def add(socket) do
    Logger.debug "Add client"
    Agent.update(@name, fn list -> [socket|list] end)
  end

  def remove(socket) do
    Logger.debug "Remove client"
    Agent.update(@name, fn list -> List.delete(list, socket) end)
  end

  def broadcast(message, payload) do
    Enum.each(all, fn socket -> Phoenix.Channel.push(socket, message, payload) end)
  end

  defp all do
    Agent.get(@name, fn list -> list end)
  end
end