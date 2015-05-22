defmodule Mix.Tasks.Assets.Compile do
  use Mix.Task

  @shortdoc "Compiles all JS and CSS assets via webpack"

  @moduledoc """
    "Builds minified and optimized JS and CSS webpack build"
  """

  def run(_args) do
    Mix.shell.info "Building static assets using webpack"
    Mix.shell.cmd "node node_modules/webpack/bin/webpack.js --colors --progress --optimize-minimize"
  end
end