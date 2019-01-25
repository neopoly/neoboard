defmodule Neoboard.Mixfile do
  use Mix.Project

  def project do
    [app: :neoboard,
     version: "0.0.1",
     elixir: "~> 1.8",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {Neoboard, []},
    extra_applications: [
       :phoenix,
       :phoenix_html,
       :phoenix_pubsub,
       :timex,
       :logger,
       :httpoison,
       :xmerl,
       :tzdata]]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, "~> 1.4"},
     {:phoenix_html, "~> 2.13"},
     {:phoenix_live_reload, "~> 1.2", only: :dev},
     {:bypass, "~> 1.0", only: :test},
     {:plug_cowboy, "~> 2.0"},
     {:timex, "~> 3.5"},
     {:httpoison, "~> 1.5"},
     {:jason, "~> 1.1"},
     {:distillery, "~> 1.1"},
     {:tzdata, "~> 0.5.19"}]
  end
end
