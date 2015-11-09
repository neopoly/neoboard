defmodule Neoboard.WidgetSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    cond do
      Neoboard.Widgets.auto_start? ->
        children = Enum.map(Neoboard.Widgets.enabled, &(worker(&1, [])))
      true ->
        children = []
    end
    supervise(children, strategy: :one_for_one, max_restarts: 20)
  end
end