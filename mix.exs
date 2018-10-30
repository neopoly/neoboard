defmodule Neoboard.Mixfile do
  use Mix.Project

  def project do
    [app: :neoboard,
     version: "0.0.1",
     elixir: "~> 1.4",
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
     applications: [
       :phoenix,
       :phoenix_html,
       :phoenix_pubsub,
       :timex,
       :cowboy,
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
    [{:phoenix, "~> 1.3"},
     {:phoenix_html, "~> 2.9"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:bypass, "~> 0.9", only: :test},
     {:plug_cowboy, "~> 1.0"},
     {:timex, "~> 3.1"},
     {:httpoison, "~> 0.11"},
     {:distillery, "~> 1.1"}]
  end
end
