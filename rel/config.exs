use Mix.Releases.Config,
  default_release: :default,
  default_environment: :prod

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: System.get_env("NEOBOARD_COOKIE")
end

release :neoboard do
  set version: current_version(:neoboard)
end
