defmodule Neoboard.Widgets.Gitter do
  use GenServer
  use Neoboard.Pusher
  use Neoboard.Config

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, :ok)
    GenServer.cast(pid, :listen)
    {:ok, pid}
  end

  def init(:ok) do
    {:ok, []}
  end

  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, state) do
    cond do
      String.match?(chunk, ~r/\{.*\}/) ->
        message = chunk |> Poison.decode!
        updated = [message | state] |> Enum.take(config()[:messages])
        push_messages! updated
        {:noreply, updated}
      true ->
        # ignore all whitespace and other nonsense
        {:noreply, state}
    end
  end

  def handle_info(%HTTPoison.AsyncEnd{}, state) do
    # in this case something went wrong, so lets crash
    {:stop, "Stream ended", state}
  end

  def handle_info(request, state) do
    super(request, state)
  end

  def handle_cast(:listen, _state) do
    messages = fetch()
    push_messages! messages
    do_listen()
    {:noreply, messages}
  end

  defp fetch do
    case HTTPoison.get(url(), headers()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body |> Poison.decode! |> Enum.reverse
    end
  end

  defp push_messages!(messages) do
    push! %{messages: messages, title: config()[:title]}
  end

  defp headers do
    %{
      "Authorization" => "Bearer #{config()[:token]}",
      "Accept" => "application/json"
    }
  end

  defp url(host \\ "api.gitter.im") do
    room     = config()[:room]
    messages = config()[:messages]
    "https://#{host}/v1/rooms/#{room}/chatMessages?limit=#{messages}"
  end

  defp do_listen do
    HTTPoison.get! url("stream.gitter.im"), headers(), [
      stream_to: self(),
      recv_timeout: :infinity]
  end
end
