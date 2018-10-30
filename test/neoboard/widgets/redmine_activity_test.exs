defmodule Neoboard.Widgets.RedmineActivityTest do
  use ExUnit.Case, async: true
  alias Neoboard.Widgets.RedmineActivity.Parser

  setup do
    {:ok, xml: load_fixture!()}
  end

  test "parser collects projects", %{xml: xml} do
    %{projects: projects}  = Parser.parse!(xml)
    [first | two_projects] = projects
    assert first.name       == "project1"
    assert first.activity   == 2
    assert first.updated_at == ~N[2015-05-19 10:19:27] |> Timex.to_datetime
    [user | rest] = first.users
    assert user.email == "aa@company.com"
    [user | rest] = rest
    assert user.email == "mm@company.com"
    assert Enum.empty?(rest)

    [second | one_project] = two_projects
    assert second.name       == "project3 & [møre]"
    assert second.activity   == 1
    assert second.updated_at == ~N[2015-05-18 15:02:59] |> Timex.to_datetime
    [user | rest] = second.users
    assert user.email == "pp@company.com"
    assert Enum.empty?(rest)

    [third | rest] = one_project
    assert Enum.empty?(rest)
    assert third.name       == "project2"
    assert third.activity   == 1
    assert third.updated_at == ~N[2015-05-19 10:07:33] |> Timex.to_datetime
    [user | rest] = third.users
    assert user.email == "aa@company.com"
    assert Enum.empty?(rest)
  end

  test "parser collects users", %{xml: xml} do
    %{users: users} = Parser.parse!(xml)
    [user | users] = users
    assert user.email == "aa@company.com"
    [user | users] = users
    assert user.email == "mm@company.com"
    [user | users] = users
    assert user.email == "pp@company.com"
    assert Enum.empty?(users)
  end

  defp load_fixture! do
    Path.join(__DIR__, "redmine_activity_fixture.xml")
    |> File.read!
  end
end

defmodule Neoboard.Widgets.RedmineActivity.XmlTest do
  use ExUnit.Case, async: true
  alias Neoboard.Widgets.RedmineActivity.Xml

  test "handles text nodes with ampersand" do
    source = Xml.load_xml("<title>code &amp; fun</title>")
    assert Xml.text(source) == "code & fun"
  end
end
