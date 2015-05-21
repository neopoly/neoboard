defmodule Neoboard.Widgets.OwncloudImages do
  use GenServer
  use Neoboard.Pusher
  use Neoboard.Config
  alias Neoboard.Widgets.OwncloudImages.Parser

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, :ok)
    GenServer.cast(pid, :fetch)
    {:ok, pid}
  end

  def init(:ok) do
    :random.seed(:os.timestamp)
    {:ok, %{images: [], count: 0, current: 0}}
  end

  def handle_cast(:fetch, _) do
    state = push_image!(reset!)
    {:noreply, state}
  end

  def handle_info(:tick, %{images: []}) do
    state = push_image!(reset!)
    {:noreply, state}
  end

  def handle_info(:tick, state) do
    {:noreply, push_image!(state)}
  end

  defp reset! do
    images = Parser.parse!(config[:url]) |> Enum.shuffle
    %{images: images, count: length(images), current: 0}
  end

  defp push_image!(%{images: [%{name: name, url: url, path: path} | images], current: current, count: count}) do
    next = current + 1
    push! %{name: name, url: url, path: path, current: next, count: count}
    :timer.send_after(config[:every], self, :tick)
    %{images: images, current: next, count: count}
  end
end

defmodule Neoboard.Widgets.OwncloudImages.Parser do
  alias Neoboard.Widgets.OwncloudImages.FolderDoc

  def parse!(source) do
    collect_images(%{url: source})
  end

  defp load!(url) do
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.get(url)
    body
  end

  defp collect_images([]), do: []
  defp collect_images([folder | tail]) do
    collect_images(folder) ++ collect_images(tail)
  end
  defp collect_images(%{url: url}) do
    doc     = load!(url)
    folders = FolderDoc.find_folders(doc, url)
    images  = FolderDoc.find_images(doc)
    collect_images(folders) ++ images
  end
end

defmodule Neoboard.Widgets.OwncloudImages.FolderDoc do
  alias Neoboard.Widgets.OwncloudImages.DocHelper

  def find_folders(doc, base_url) do
    doc
    |> DocHelper.all(~r{<tr[^>]+data-type="dir".*</tr>}isr)
    |> Enum.map(fn row ->
      name = file_name(row)
      url  = build_folder_url(base_url, name)
      %{name: name, url: url}
    end)
  end

  def find_images(doc) do
    path = extract_path(doc)
    doc
    |> DocHelper.all(~r{<tr[^>]+data-mime="image/\w+".*</tr>}isr)
    |> Enum.map(fn row ->
      name = file_name(row)
      url  = image_url(row)
      %{name: name, url: url, path: path}
    end)
  end

  defp image_url(row) do
    row
    |> DocHelper.extract_element_attribute("a", "class=\"name\"", "href")
    |> decode_uri
    |> String.replace("&amp;", "&")
  end

  def extract_path(doc) do
    doc
    |> DocHelper.extract_input_value("dir")
    |> decode_uri
  end

  defp build_folder_url(base_url, folder) do
    uri     = URI.parse(base_url)
    query   = URI.decode_query(uri.query || "", %{"path" => ""})
    updated = Dict.put(query, "path", query["path"] <> "\\" <> folder)
    to_string(%{uri | query: URI.encode_query(updated)})
  end

  defp file_name(doc) do
    doc
    |> DocHelper.first(~r{data-file="([^"]+)"}i)
    |> decode_uri
  end

  defp decode_uri(uri), do: URI.decode_www_form(uri)
end

defmodule Neoboard.Widgets.OwncloudImages.DocHelper do
  def all(doc, regex) do
    Regex.scan(regex, doc) |> List.flatten
  end

  def first(doc, regex) do
    Regex.run(regex, doc, capture: :all_but_first)
    |> List.first
  end

  def extract_element_attribute(doc, tag, selector, attribute) do
    doc
    |> first(~r{(<#{tag}[^>]+#{selector}[^>]+>)}i)
    |> first(~r{#{attribute}="([^"]*)"}i)
  end

  def extract_input_value(doc, name) do
    doc
    |> extract_element_attribute("input", "name=\"#{name}\"", "value")
  end
end