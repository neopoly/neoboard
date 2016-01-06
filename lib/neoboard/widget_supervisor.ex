defmodule Neoboard.WidgetSupervisor do
  alias Neoboard.ProcessCushion
  use Supervisor

  @delay 10_000 # at least 10 seconds for exiting widgets
  @shutdown_timeout 1_000 # wait 1 second when shutting down widgets

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = cond do
      Neoboard.Widgets.auto_start? ->
        Enum.map(Neoboard.Widgets.enabled, &worker_cushion/1)
      true ->
        []
    end
    supervise(children, strategy: :one_for_one, max_restarts: 20)
  end

  defp worker_cushion(module) do
    id = "#{module}Cushion"
    worker(ProcessCushion, [id, @delay, @shutdown_timeout, module], id: id)
  end
end
