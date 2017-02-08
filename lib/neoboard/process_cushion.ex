defmodule Neoboard.ProcessCushion do
  use GenServer
  require Logger

  defmodule State do
    defstruct [
      :name, :delay, :started, :child_pid, :shutdown_timeout,
      :module, :fun, :args
    ]
  end

  def start_link(name, delay, shutdown_timeout,
                 module, fun \\ :start_link, args \\ []) do
    state = %State{
      name: name,
      delay: delay,
      shutdown_timeout: shutdown_timeout,
      module: module,
      fun: fun,
      args: args
    }
    GenServer.start_link(__MODULE__, state)
  end

  def child_pid(pid) do
    GenServer.call(pid, :child_pid)
  end

  def init(state) do
    Logger.info("[ProcessCushion] Starting #{state.module} with" <>
                 " delay of #{state.delay}")
    Process.flag(:trap_exit, true)
    {:ok, child_pid} = apply(state.module, state.fun, state.args)
    Logger.debug("[ProcessCushion] Child process is #{inspect(child_pid)}")
    {:ok, %{state | child_pid: child_pid, started: now()}}
  end

  def handle_call(:child_pid, _, state) do
    {:reply, state.child_pid, state}
  end
  def handle_call(_, _, state), do: {:reply, :ok, state}

  def handle_cast(_, state), do: {:noreply, state}

  def handle_info({:EXIT, _, reason}, state) do
    Logger.info("[ProcessCushion] Managed process #{state.name}" <>
                 " exited: #{inspect(reason)}")
    {:noreply, die_slowly(reason, state)}
  end
  def handle_info({:die, reason}, state), do: {:stop, reason, state}
  def handle_info(_, state), do: {:noreply, state}

  def terminate(:shutdown, _), do: :ok
  def terminate(_, %State{child_pid: nil}), do: :ok
  def terminate({%Protocol.UndefinedError{} = reason, _}, state) do
    Logger.info("[ProcessCushion] Managed process #{state.name}" <>
                 " errored: #{inspect(reason)}")
    die_slowly(reason, state)
  end
  def terminate(reason, %State{child_pid: pid, shutdown_timeout: timeout}) do
    Process.exit(pid, reason)
    receive do
      {:EXIT, ^pid, _} -> :ok
    after
      timeout ->
        Logger.warn("[ProcessCushion] Failed to terminate #{inspect(pid)}" <>
                    " within #{timeout}. Killing now brutally.")
        Process.exit(pid, :kill)
        receive do
          {:EXIT, ^pid, _} -> :ok
        end
    end
  end

  defp die_slowly(reason, state) do
    # time the process was running in microseconds
    lifetime = :timer.now_diff(now(), state.started)
    # delay in microseconds
    min_delay = state.delay * 1000
    # if the exit was to soon slow down a bit
    case lifetime < min_delay do
      true ->
        Logger.info("[ProcessCushion] Service #{state.name} exited on node" <>
                    " #{node()} in #{lifetime}. Delay exit!")
        :timer.send_after(state.delay, self(), {:die, reason})
      _ ->
        Logger.debug("[ProcessCushion] Service #{state.name} exited late." <>
                     " Exit now!")
        send(self(), {:die, reason})
    end
    %{state | child_pid: nil}
  end

  defp now() do
    :os.timestamp
  end
end
