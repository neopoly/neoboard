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

  defp push_image!(%{images: [{name, url} | images], current: current, count: count}) do
    next = current + 1
    push! %{name: name, url: url, current: next, count: count}
    :timer.send_after(config[:every], self, :tick)
    %{images: images, current: next, count: count}
  end
end

defmodule Neoboard.Widgets.OwncloudImages.Folder do
  defstruct name: nil, url: nil
  @type t :: %__MODULE__{name: String.t, url: String.t}

  def build({name, url}) do
    %__MODULE__{name: name, url: url}
  end
end

defmodule Neoboard.Widgets.OwncloudImages.Image do
  defstruct name: nil, url: nil
  @type t :: %__MODULE__{name: String.t, url: String.t}

  def build({name, url}) do
    %__MODULE__{name: name, url: url}
  end
end

defmodule Neoboard.Widgets.OwncloudImages.Parser do
  alias Neoboard.Widgets.OwncloudImages.Folder
  alias Neoboard.Widgets.OwncloudImages.Image
  alias Neoboard.Widgets.OwncloudImages.FolderDoc
  alias Neoboard.Widgets.OwncloudImages.ImageDoc

  def parse!(source) do
    folder = %Folder{url: source}
    collect_images(folder)
  end

  defp load!(url) do
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.get(url)
    body
  end

  defp collect_images([]), do: []
  defp collect_images([%Folder{} = folder | tail]) do
    collect_images(folder) ++ collect_images(tail)
  end
  defp collect_images(%Folder{url: url}) do
    doc = load!(url)
    folders =
      FolderDoc.find_folders(doc, url)
      |> Enum.map(&Folder.build/1)
    images =
      FolderDoc.find_images(doc, url)
      |> Enum.map(&Image.build/1)
    collect_images(folders) ++ collect_images(images)
  end
  defp collect_images([%Image{} = image | tail]) do
    [collect_image(image) | collect_images(tail)]
  end
  defp collect_image(%Image{url: url}) do
    image = load!(url) |> ImageDoc.extract_image
    image
  end
end

defmodule Neoboard.Widgets.OwncloudImages.FolderDoc do
  def find_folders(doc, base_url) do
    doc
    |> all(~r{<tr[^>]+data-type="dir".*</tr>}isr)
    |> Enum.map(&(extract_name_and_url(&1, base_url)))
  end

  def find_images(doc, base_url) do
    doc
    |> all(~r{<tr[^>]+data-mime="image/\w+".*</tr>}isr)
    |> Enum.map(&(extract_name_and_url(&1, base_url)))
  end

  defp extract_name_and_url(row, base_url) do
    name = file_name(row)
    url  = build_folder_url(base_url, name)
    {name, url}
  end

  defp build_folder_url(base_url, folder) do
    uri     = URI.parse(base_url)
    query   = URI.decode_query(uri.query || "", %{"path" => ""})
    updated = Dict.put(query, "path", query["path"] <> "\\" <> folder)
    to_string(%{uri | query: URI.encode_query(updated)})
  end

  defp all(doc, regex) do
    Regex.scan(regex, doc) |> List.flatten
  end

  defp file_name(doc) do
    Regex.run(~r{data-file="([^"]+)"}i, doc, capture: :all_but_first)
    |> List.first
    |> URI.decode_www_form
  end
end

defmodule Neoboard.Widgets.OwncloudImages.ImageDoc do
  def extract_image(doc) do
    name =
      doc
      |> extract_input_value("dir")
      |> transform_dir_to_name
    url =
      doc
      |> extract_input_value("downloadURL")
      |> fix_url
    {name, url}
  end

  defp transform_dir_to_name(string) do
    string
    |> String.split("/")
    |> Enum.reject(&(String.length(&1) == 0))
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" / ")
  end

  defp fix_url(string) do
    string
    |> URI.decode
    |> String.replace("&amp;", "&")
  end

  defp extract_input_value(doc, name) do
    doc
    |> first(~r{(<input[^>]+name="#{name}"[^>]+>)}i)
    |> first(~r{value="([^"]+)"}i)
  end

  defp first(doc, regex) do
    Regex.run(regex, doc, capture: :all_but_first)
    |> List.first
  end
end