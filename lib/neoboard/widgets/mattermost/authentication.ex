defmodule Neoboard.Widgets.Mattermost.Authentication do
  alias Neoboard.Widgets.Mattermost.Authentication

  defstruct [:api_url, :login_id, :password, :private_token]

  def login(config) do
    %Authentication{
      api_url: config[:api_url],
      login_id: config[:login_id],
      password: config[:password]
    } |> do_login
  end

  defp do_login(authentication = %Authentication{login_id: login_id, password: password}) do
    {:ok, payload} = Poison.encode(%{login_id: login_id, password: password})
    token = url(authentication, "users/login")
    |> request_headers(payload)
    |> extract_token
    {:ok, %{authentication | private_token: token}}
  end

  defp request_headers(url, body) do
    result = HTTPoison.post(url, body)
    {:ok, %HTTPoison.Response{status_code: 200, headers: headers}} = result
    headers
  end

  defp extract_token(headers) do
    {_, token} = Enum.find(headers, fn {name, _} -> name == "Token" end)
    token
  end

  defp url(%Authentication{api_url: url}, path) do
    "#{url}/#{path}"
  end
end
