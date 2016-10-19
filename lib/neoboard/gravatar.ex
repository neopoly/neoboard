defmodule Neoboard.Gravatar do
  def url(email) do
    %URI{scheme: "https", host: "secure.gravatar.com/avatar/"}
    |> add_email(email)
    |> to_string
  end

  defp add_email(uri, email) do
    %URI{uri | path: hash_email(email)}
  end

  defp hash_email(email) do
    email
    |> String.trim
    |> String.downcase
    |> md5
    |> Base.encode16(case: :lower)
  end

  defp md5(string) do
    :crypto.hash(:md5, string)
  end
end
