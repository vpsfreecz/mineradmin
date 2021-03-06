defmodule MinerAdmin.Miner.Worker do
  use GenServer
  require Logger
  alias MinerAdmin.Miner
  alias MinerAdmin.Base

  # Client API
  def start_link(prog, opts) do
    GenServer.start_link(__MODULE__, %{
      program: prog,
      minerd: nil,
      id: nil,
      running: nil,
      subscribers: [],
      monitors: [],
    }, opts)
  end

  def remove(prog) do
    GenServer.stop(via_tuple(prog), :normal)
  end

  def start(prog, session) do
    GenServer.call(via_tuple(prog), {:start, prog, session})
  end

  def stop(prog, session) do
    GenServer.call(via_tuple(prog), {:stop, prog, session})
  end

  def attach(prog, receiver) do
    GenServer.call(via_tuple(prog), {:attach, receiver})
  end

  def running?(prog) do
    GenServer.call(via_tuple(prog), :running?)
  end

  def monitor(prog, receiver) do
    GenServer.call(via_tuple(prog), {:monitor, prog, receiver})
  end

  def via_tuple(prog) do
    {:via, Registry, {Miner.Registry, {:worker, prog.id}}}
  end

  # Server implementation
  def init(state) do
    Process.flag(:trap_exit, true)
    GenServer.cast(self(), :startup)
    {:ok, state}
  end

  def handle_cast(:startup, state) do
    case Miner.MinerdClient.start_link do
      {:ok, pid} ->
        startup(%{state | minerd: pid}, state.program.active)

      {:error, _reason} ->
        # Worker will receive EXIT message and reconnect from there
        {:noreply, state}
    end
  end

  def handle_call({:start, _prog, _session}, _from, %{minerd: nil} = state) do
    {:reply, {:error, :not_connected}, state}
  end

  def handle_call({:start, prog, session}, _from, state) do
    if state.running do
      {:reply, :already_running, state}

    else
      case do_start(%{state | program: prog}, session) do
        {:ok, state} ->
          {:reply, :ok, state}

        {:error, msg, state} ->
          {:stop, msg, state}
      end
    end
  end

  def handle_call({:stop, _prog, _session}, _from, %{minerd: nil} = state) do
    {:reply, {:error, :not_connected}, state}
  end

  def handle_call({:stop, prog, session}, _from, state) do
    if state.running do
      :ok = Miner.MinerdClient.detach(state.minerd)
      :ok = Miner.MinerdClient.stop(state.minerd, state.id)
      Base.UserProgramLog.log(prog, session, :stop, nil)
      {:reply, :ok, %{state | program: prog} |> set_status(false)}

    else
      {:reply, :not_started, state}
    end
  end

  def handle_call({:attach, receiver}, _from, state) do
    ref = Process.monitor(receiver)
    myself = self()
    write = fn data -> send(myself, {:stream, :write_encoded, data}) end
    resize = fn w, h -> send(myself, {:stream, :resize, {w, h}}) end

    Logger.debug "Attaching socket subscriber to miner worker"

    {
      :reply,
      {:ok, self(), %{write: write, resize: resize}},
      %{state | subscribers: [{ref, receiver} | state.subscribers]}
    }
  end

  def handle_call(:running?, _from, state) do
    {:reply, state.running, state}
  end

  def handle_call({:monitor, prog, receiver}, _from, state) do
    ref = Process.monitor(receiver)

    {
      :reply,
      {self(), state.running},
      %{state | monitors: [{ref, receiver} | state.monitors]}
    }
  end

  def handle_info(:reconnect, state) do
    handle_cast(:startup, state)
  end

  # MinerdClient exited
  def handle_info({:EXIT, _from, _reason}, state) do
    Logger.warn "Lost connection to minerd, reconnecting in 5s"
    Process.send_after(self(), :reconnect, 5*1000)
    {:noreply, %{state | minerd: nil} |> set_status(false)}
  end

  # Subscriber or monitor has exited
  def handle_info({:DOWN, ref, :process, pid, reason}, state) do
    if List.keyfind(state.subscribers, ref, 0) do
      Logger.debug "Subscriber has exited with #{reason}"
      {:noreply, update_in(state.subscribers, &List.delete(&1, {ref, pid}))}

    else
      Logger.debug "Monitor has exited with #{reason}"
      {:noreply, update_in(state.monitors, &List.delete(&1, {ref, pid}))}
    end
  end

  # Output from MinerdClient
  def handle_info({:minerd, _from, :data, data}, state) do
    for {_ref, sub} <- state.subscribers do
      send(sub, {:user_program, :output, data})
    end

    {:noreply, state}
  end

  def handle_info({:minerd, _from, :exit, status}, state) do
    Logger.debug "Process exited with status #{status}, restarting in 5s"
    Base.UserProgramLog.log(state.program, nil, :exit, %{status: status})
    Process.send_after(self(), :autorestart, 5000)
    {:noreply, set_status(state, false)}
  end

  def handle_info({:stream, _cmd, _data}, %{running: false} = state) do
    {:noreply, state}
  end

  def handle_info({:stream, :write_encoded, data}, state) do
    unless Base.Program.read_only?(state.program) do
      Miner.MinerdClient.write_encoded(state.minerd, data)
    end

    {:noreply, state}
  end

  def handle_info({:stream, :resize, {w, h}}, state) do
    Miner.MinerdClient.resize(state.minerd, w, h)
    {:noreply, state}
  end

  def handle_info(:autorestart, %{running: true} = state) do
    # The process has been already started in the meantime
    {:noreply, state}
  end

  def handle_info(:autorestart, %{running: false} = state) do
    case do_start(state) do
      {:ok, state} ->
        {:noreply, state}

      {:error, msg, state} ->
        {:stop, msg, state}
    end
  end

  def terminate(:normal, state) do
    if state.running do
      :ok = Miner.MinerdClient.detach(state.minerd)
      :ok = Miner.MinerdClient.stop(state.minerd, state.id)
    end

    :ok
  end

  def terminate(_other, _state), do: :ok

  defp startup(state, true) do
    case do_start(state) do
      {:ok, state} ->
        {:noreply, state}

      {:error, msg, state} ->
        {:stop, msg, state}
    end
  end

  defp startup(state, false) do
    {:noreply, set_status(state, false)}
  end

  defp do_start(state, session \\ nil) do
    {id, cmd, args} = Base.Program.command(state.program)

    case Miner.MinerdClient.start(state.minerd, id, cmd, args) do
      :ok ->
        Base.UserProgramLog.log(state.program, session, :start, %{
          command: cmd,
          arguments: args,
        })
        {:ok, do_attach(state, id)}

      {:error, "ALREADY STARTED"} ->
        {:ok, do_attach(state, id)}

      {:error, msg} ->
        {:error, msg, set_status(state, false)}
    end
  end

  defp do_attach(state, id) do
    Logger.debug "Attaching to minerd process #{id}"
    :ok = Miner.MinerdClient.attach(state.minerd, id, self())
    %{state | id: id} |> set_status(true)
  end

  defp set_status(state, status) do
    for {_ref, pid} <- state.monitors do
      send(pid, {:user_program, :monitor, state.program.id, status})
    end

    %{state | running: status}
  end
end
