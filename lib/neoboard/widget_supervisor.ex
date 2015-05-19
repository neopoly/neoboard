defmodule Neoboard.WidgetSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = Enum.map(Neoboard.Widgets.enabled, &(worker(&1, [])))
    supervise(children, strategy: :one_for_one)
  end
end