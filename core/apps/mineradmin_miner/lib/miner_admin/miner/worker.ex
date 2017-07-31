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
    }, opts)
  end

  def remove(prog) do
    GenServer.stop(via_tuple(prog), :normal)
  end

  def start(prog) do
    GenServer.call(via_tuple(prog), {:start, prog})
  end

  def stop(prog) do
    GenServer.call(via_tuple(prog), {:stop, prog})
  end

  def attach(prog, receiver) do
    GenServer.call(via_tuple(prog), {:attach, receiver})
  end

  def running?(prog) do
    GenServer.call(via_tuple(prog), :running?)
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
    {:ok, pid} = Miner.MinerdClient.start_link

    startup(%{state | minerd: pid}, state.program.active)
  end

  def handle_call({:start, prog}, _from, state) do
    if state.running do
      {:reply, :already_running, state}

    else
      case do_start(%{state | program: prog}) do
        {:ok, state} ->
          {:reply, :ok, state}

        {:error, msg, state} ->
          {:stop, msg, state}
      end
    end
  end

  def handle_call({:stop, prog}, _from, state) do
    if state.running do
      :ok = Miner.MinerdClient.detach(state.minerd)
      :ok = Miner.MinerdClient.stop(state.minerd, state.id)
      {:reply, :ok, %{state | program: prog, running: false}}

    else
      {:reply, :not_started, state}
    end
  end

  def handle_call({:attach, receiver}, _from, state) do
    ref = Process.monitor(receiver)
    myself = self()
    write = fn data -> send(myself, {:write_encoded, data}) end
    resize = fn w, h -> send(myself, {:resize, w, h}) end

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

  # MinerdClient exited
  def handle_info({:EXIT, _from, :closed}, state) do
    # Restart the server, open new connection to minerd
    handle_cast(:startup, %{state | minerd: nil, running: false})
  end

  # A subscriber has exited
  def handle_info({:DOWN, ref, :process, pid, reason}, state) do
    Logger.debug "Subscriber has exited with #{reason}"
    {:noreply, update_in(state.subscribers, &List.delete(&1, {ref, pid}))}
  end

  # Output from MinerdClient
  def handle_info({:minerd, _from, data}, state) do
    for {_ref, sub} <- state.subscribers do
      send(sub, {:user_program, :output, data})
    end

    {:noreply, state}
  end

  def handle_info({:write_encoded, data}, state) do
    Miner.MinerdClient.write_encoded(state.minerd, data)
    {:noreply, state}
  end

  def handle_info({:resize, w, h}, state) do
    Miner.MinerdClient.resize(state.minerd, w, h)
    {:noreply, state}
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
    {:noreply, %{state | running: false}}
  end

  defp do_start(state) do
    {id, cmd, args} = Base.Program.command(state.program)

    case Miner.MinerdClient.start(state.minerd, id, cmd, args) do
      :ok ->
        {:ok, do_attach(state, id)}

      {:error, "ALREADY STARTED"} ->
        {:ok, do_attach(state, id)}

      {:error, msg} ->
        {:error, msg, %{state | running: false}}
    end
  end

  defp do_attach(state, id) do
    Logger.debug "Attaching to minerd process #{id}"
    :ok = Miner.MinerdClient.attach(state.minerd, id, self())
    %{state | id: id, running: true}
  end
end
