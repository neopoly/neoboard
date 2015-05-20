defmodule Neoboard.Widgets.OwncloudImagesTest do
  use ExUnit.Case, async: true
  use Timex
  alias Neoboard.Widgets.OwncloudImages.FolderDoc
  alias Neoboard.Widgets.OwncloudImages.ImageDoc

  setup do
    {:ok, html_folder: load_fixture!("folder"), html_image: load_fixture!("image")}
  end

  test "doc finds all folders without base path", %{html_folder: doc} do
    folders = FolderDoc.find_folders(doc, "https://base.url/")
    assert folders == [
      {"folder1", "https://base.url/?path=%5Cfolder1"},
      {"folder2", "https://base.url/?path=%5Cfolder2"},
      {"folder3", "https://base.url/?path=%5Cfolder3"}
    ]
  end

  test "doc finds all folders with base path", %{html_folder: doc} do
    folders = FolderDoc.find_folders(doc, "https://base.url/?some=1&path=%5Cparent")
    assert folders == [
      {"folder1", "https://base.url/?path=%5Cparent%5Cfolder1&some=1"},
      {"folder2", "https://base.url/?path=%5Cparent%5Cfolder2&some=1"},
      {"folder3", "https://base.url/?path=%5Cparent%5Cfolder3&some=1"}
    ]
  end

  test "doc finds all images without base path", %{html_folder: doc} do
    images = FolderDoc.find_images(doc, "https://base.url/")
    assert images == [
      {"IMG_0001.JPG", "https://base.url/?path=%5CIMG_0001.JPG"},
      {"IMG_0002.JPG", "https://base.url/?path=%5CIMG_0002.JPG"}
    ]
  end

  test "doc finds all images with base path", %{html_folder: doc} do
    images = FolderDoc.find_images(doc, "https://base.url/?path=%5Cparent&some=1")
    assert images == [
      {"IMG_0001.JPG", "https://base.url/?path=%5Cparent%5CIMG_0001.JPG&some=1"},
      {"IMG_0002.JPG", "https://base.url/?path=%5Cparent%5CIMG_0002.JPG&some=1"}
    ]
  end

  test "doc extract image", %{html_image: doc} do
    {name, url} = ImageDoc.extract_image(doc)
    assert name == "Folder1 / Subdir"
    assert url  == "https://owncloud.company.com/public.php?service=files&t=SECRET_TOKEN&download&path=/folder1/IMG_0315.JPG"
  end

  defp load_fixture!(name) do
    Path.join(__DIR__, "owncloud_images_#{name}_fixture.html")
    |> File.read!
  end
end