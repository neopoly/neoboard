defmodule Neoboard.Widgets.OwncloudImagesTest do
  use ExUnit.Case, async: true
  use Timex
  alias Neoboard.Widgets.OwncloudImages.FolderDoc

  setup do
    {:ok, doc: load_fixture!()}
  end

  test "doc finds all folders without base path", %{doc: doc} do
    folders = FolderDoc.find_folders(doc, "https://base.url/")
    assert folders == [
      %{name: "folder1", url: "https://base.url/?path=%5Cfolder1"},
      %{name: "folder2", url: "https://base.url/?path=%5Cfolder2"},
      %{name: "folder3", url: "https://base.url/?path=%5Cfolder3"}
    ]
  end

  test "doc finds all folders with base path", %{doc: doc} do
    folders = FolderDoc.find_folders(doc, "https://base.url/?some=1&path=%5Cparent")
    assert folders == [
      %{name: "folder1", url: "https://base.url/?path=%5Cparent%5Cfolder1&some=1"},
      %{name: "folder2", url: "https://base.url/?path=%5Cparent%5Cfolder2&some=1"},
      %{name: "folder3", url: "https://base.url/?path=%5Cparent%5Cfolder3&some=1"}
    ]
  end

  test "doc finds all images", %{doc: doc} do
    images = FolderDoc.find_images(doc)
    assert images == [
      %{
        name: "IMG_0001.JPG",
        url:  "https://owncloud.company.com/public.php?service=files&t=SECRET_TOKEN&download&path=/IMG_0001.JPG",
        path: "/some deep/path"
      },
      %{
        name: "IMG_0002.JPG",
        url:  "https://owncloud.company.com/public.php?service=files&t=SECRET_TOKEN&download&path=/folder1/IMG_0002.JPG",
        path: "/some deep/path"
      }
    ]
  end

  defp load_fixture! do
    Path.join(__DIR__, "owncloud_images_fixture.html")
    |> File.read!
  end
end
