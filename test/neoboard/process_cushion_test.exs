defmodule Neoboard.ProcessCushionTest do
  # these tests should not be run in parallel
  use ExUnit.Case
  alias Neoboard.ProcessCushion

  # remove console logging to prvent process to spam the console
  setup_all do
    Logger.remove_backend :console
    on_exit fn ->
      Logger.add_backend :console
    end
    :ok
  end

  setup do
    Process.flag(:trap_exit, true)
    :ok
  end

  defmodule DummyProcess do
    def foo(holder) do
      Task.start_link(__MODULE__, :start, [holder])
    end

    def start(holder) do
      Process.flag(:trap_exit, true)
      listen(holder)
    end

    def listen(holder) do
      receive do
        {:EXIT, pid, :fake_timeout} ->
          send(holder, {:exit, pid, :fake_timeout})
          :timer.send_after(15, self(), :wait)
          receive do
            :wait ->
              :ok
          end
        {:EXIT, pid, reason} ->
          send(holder, {:exit, pid, reason})
        :ping ->
          send(holder, {:ping, :pong})
          listen(holder)
        :pid ->
          send(holder, {:pid, self()})
          listen(holder)
        {:match, some} ->
          send(holder, {:match, some})
          :expect = some
        {:manual_exit, reason} ->
          send(holder, {:manual_exit, true})
          exit(reason)
        :manual_stop ->
          send(holder, {:manual_stop, true})
      end
    end
  end

  defmodule SimpleProcess do
    def start_link do
      Task.start_link(fn -> :ok end)
    end
  end

  test "it starts a sub process by module and knows child pid" do
    {_, child_pid} = cushion(10, 10)
    send(child_pid, :ping)
    assert_receive {:ping, :pong}
    send(child_pid, :pid)
    assert_receive {:pid, ^child_pid}
  end

  test "uses defaults for sub process" do
    _ = ProcessCushion.start_link(__MODULE__, 10, 10, SimpleProcess)
  end

  test "dies slowly if child process exits" do
    {pid, child_pid} = cushion(10, 10)
    wait(1)
    send(child_pid, {:manual_exit, :error})
    assert_receive {:manual_exit, true}
    wait(10)
    assert_receive {:EXIT, ^pid, :error}
  end

  test "dies directly if child was a alive long enough" do
    {pid, child_pid} = cushion(10, 10)
    wait(20)
    send(child_pid, {:manual_exit, :error})
    assert_receive {:manual_exit, true}
    wait(10)
    assert_receive {:EXIT, ^pid, :error}
  end

  test "dies slowly if child process crashes" do
    {pid, child_pid} = cushion(50, 10)
    wait(1)
    send(child_pid, {:match, :wrong})
    assert_receive {:match, :wrong}
    assert_receive {:EXIT, ^pid, error}
    {{:badmatch, :wrong}, _} = error
  end

  test "handles default late exit case " do
    {pid, child_pid} = cushion(10, 10)
    wait(20)
    send(child_pid, :manual_stop)
    assert_receive {:manual_stop, true}
    assert_receive {:EXIT, ^pid, :normal}
  end

  test "handles default early exit case " do
    {pid, child_pid} = cushion(10, 10)
    wait(1)
    send(child_pid, :manual_stop)
    assert_receive {:manual_stop, true}
    assert_receive {:EXIT, ^pid, :normal}
  end

  test "terminate shutdown child process only once" do
    {pid, _} = cushion(10, 10)
    wait(1)
    Process.exit(pid, :shutdown)
    assert_receive {:exit, ^pid, :shutdown}
    wait(1)
    Process.exit(pid, :shutdown)
    refute_receive {:exit, ^pid, :shutdown}
  end

  test "terminate does nothing if child has already existed" do
    {pid, child_pid} = cushion(10, 10)
    send(child_pid, :manual_stop)
    assert_receive {:manual_stop, true}
    Process.exit(pid, :normal)
    refute_receive {:exit, ^pid, :normal}
  end

  test "terminate tries to exit supervised process with same reason" do
    {pid, _} = cushion(10, 10)
    wait(1)
    Process.exit(pid, :error)
    assert_receive {:exit, ^pid, :error}
  end

  test "terminate kills supervised process after shutdown_timeout" do
    {pid, _} = cushion(10, 10)
    wait(1)
    Process.exit(pid, :fake_timeout)
    assert_receive {:exit, ^pid, :fake_timeout}
    assert_receive {:EXIT, ^pid, :fake_timeout}
  end

  test "handles unknown messages" do
    {pid, _} = cushion(10, 10)
    send(pid, :unknown)
  end

  test "handles unknown GenServer calls" do
    {pid, _} = cushion(10, 10)
    :ok = GenServer.call(pid, :unknown)
  end

  test "handles unknown GenServer casts" do
    {pid, _} = cushion(10, 10)
    :ok = GenServer.cast(pid, :unknown)
  end

  defp cushion(delay, shutdown_timeout) do
    {:ok, pid} = ProcessCushion.start_link(__MODULE__, delay, shutdown_timeout,
                                           DummyProcess, :foo, [self()])
    {pid, ProcessCushion.child_pid(pid)}
  end

  defp wait(time) do
    :timer.send_after(time, self(), :wait)
    assert_receive :wait
  end
end
