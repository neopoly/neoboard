defmodule Neoboard.Broadcaster do
  use GenServer
  require Logger

  @topic "board:neo"
  @name __MODULE__

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def messages do
    GenServer.call(@name, :join)
  end

  def broadcast!(message, payload) do
    Logger.debug("[#{@topic}] #{message} -> #{Jason.encode!(payload)}")
    save(message, payload)
    Neoboard.Endpoint.broadcast!(@topic, message, payload)
  end

  def handle_cast({:push, message, payload}, state) do
    {:noreply, Map.put(state, message, payload)}
  end

  def handle_call(:join, _from, state) do
    {:reply, state, state}
  end

  defp save(message, payload) do
    GenServer.cast(@name, {:push, message, payload})
  end
end
