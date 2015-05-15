defmodule Neoboard do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(Neoboard.Endpoint, []),
      # Here you could define other workers and supervisors as children
      # worker(Neoboard.Widget.Time, [arg1, arg2, arg3]),
      worker(Neoboard.Widgets.Time, []),
      worker(Neoboard.Widgets.Jenkins, []),
      worker(Neoboard.Widgets.Notepad, []),
      worker(Neoboard.Widgets.NichtLustig, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Neoboard.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Neoboard.Endpoint.config_change(changed, removed)
    :ok
  end
end
