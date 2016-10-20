defmodule Neoboard.GravatarTest do
  use ExUnit.Case, async: true
  alias Neoboard.Gravatar

  test "it builds the url with hashed email" do
    url = Gravatar.url("MyEmailAddress@example.com")
    assert url == "https://secure.gravatar.com/avatar/0bc83cb571cd1c50ba6f3e8a78ef1346"
  end
end
