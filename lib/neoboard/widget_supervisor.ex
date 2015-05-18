defmodule Neoboard.WidgetSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      # Here you could define other workers
      # worker(Neoboard.Widget.Time, [arg1, arg2, arg3]),
      worker(Neoboard.Widgets.Time, []),
      worker(Neoboard.Widgets.Jenkins, []),
      worker(Neoboard.Widgets.Notepad, []),
      worker(Neoboard.Widgets.NichtLustig, []),
      worker(Neoboard.Widgets.RedmineProjectTable, []),
      worker(Neoboard.Widgets.Gitter, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end