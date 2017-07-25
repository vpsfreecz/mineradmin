defmodule MinerAdmin.Miner.MinerdClient do
  @moduledoc """
  A client for working with a local instance of Minerd.

  The client can work in two modes: command and interactive. When started,
  it is in a command mode, where `status/1`, `list/1`, `start/4`, `stop/2`
  `attach/3` and `close/1` can be used.

  If `attach/3` returns `:ok`, the client switches into interactive mode.
  In interactive mode, the client can access stdin/stdout of the program running
  within minerd. Received data is sent to configured receiver via messages
  as a tuple `{:minerd, sender_pid, data}`. Writes can be sent using `write/2`.
  Use `detach/1` to end the interactive mode, or `close/1` to close
  the connection.
  """

  use GenServer

  # Client API
  def start_link do
    GenServer.start_link(__MODULE__, %{
      socket: nil,
      queue: :queue.new,
      mode: :cmd,
      receiver: nil,
    })
  end

  def status(pid) do
    GenServer.call(pid, :status)
  end

  def list(pid) do
    GenServer.call(pid, :list)
  end

  def start(pid, id, cmd, args) do
    GenServer.call(pid, {:start, id, cmd, args})
  end

  def stop(pid, id) do
    GenServer.call(pid, {:stop, id})
  end

  def attach(pid, id, receiver) do
    GenServer.call(pid, {:attach, id, receiver})
  end

  def write(pid, data) do
    GenServer.cast(pid, {:write, data})
  end

  def resize(pid, width, height) do
    GenServer.cast(pid, {:resize, width, height})
  end

  def detach(pid) do
    GenServer.call(pid, :detach)
  end

  def close(pid) do
    GenServer.call(pid, :close)
  end

  # Server implementation
  def init(state) do
    {:ok, socket} = :gen_tcp.connect('localhost', 5000, active: true, packet: :line)
    {:ok, %{state | socket: socket}}
  end

  def handle_call(:status, from, state) do
    :gen_tcp.send(state.socket, "STATUS\n")
    {:noreply, %{state | queue: :queue.in({:status, from}, state.queue)}}
  end

  def handle_call(:list, from, state) do
    :gen_tcp.send(state.socket, "LIST\n")
    {:noreply, %{state | queue: :queue.in({:list, from}, state.queue)}}
  end

  def handle_call({:start, id, cmd, args}, from, state) do
    :gen_tcp.send(state.socket, "START #{id} #{cmd} #{Enum.join(args, " ")}\n")
    {:noreply, %{state | queue: :queue.in({:start, from}, state.queue)}}
  end

  def handle_call({:stop, id}, from, state) do
    :gen_tcp.send(state.socket, "STOP #{id}\n")
    {:noreply, %{state | queue: :queue.in({:stop, from}, state.queue)}}
  end

  def handle_call({:attach, id, receiver}, from, state) do
    :gen_tcp.send(state.socket, "ATTACH #{id}\n")
    {:noreply, %{state |
      queue: :queue.in({:attach, from}, state.queue),
      receiver: receiver
    }}
  end

  def handle_call(:detach, _from, %{mode: :attached} = state) do
    :gen_tcp.send(state.socket, "Q\n")
    :inet.setopts(state.socket, packet: :line)
    {:reply, :ok, %{state | mode: :cmd, receiver: nil}}
  end

  def handle_call(:close, _from, state) do
    :ok = :gen_tcp.close(state.socket)
    {:stop, :normal, state}
  end

  def handle_cast({:write, data}, %{mode: :attached} = state) do
    :gen_tcp.send(state.socket, "W #{Base.encode64(data)}\n")
    {:noreply, state}
  end

  def handle_cast({:resize, w, h}, %{mode: :attached} = state) do
    :gen_tcp.send(state.socket, "S #{w} #{h}\n")
    {:noreply, state}
  end

  def handle_info({:tcp, _socket, msg}, %{mode: :cmd} = state) do
    {{:value, item}, queue} = :queue.out(state.queue)
    {:noreply, handle_resp(item, msg, %{state | queue: queue})}
  end

  def handle_info({:tcp, _socket, msg}, %{mode: :attached} = state) do
    send(state.receiver, {:minerd, self(), msg})
    {:noreply, state}
  end

  def handle_info({:tcp_closed, _socket}, state) do
    {:stop, :normal, state}
  end

  def handle_info({:tcp_error, _socket, reason}, state) do
    {:stop, reason, state}
  end

  defp handle_resp({:attach, from}, msg, state) do
    ret = msg
      |> to_string()
      |> String.strip()
      |> parse_resp()

    GenServer.reply(from, ret)

    if ret == :ok do
      :inet.setopts(state.socket, packet: :raw)
      %{state | mode: :attached}

    else
      %{state | receiver: nil}
    end
  end

  defp handle_resp({:list, from}, msg, state) do
    GenServer.reply(from, Poison.decode!(msg, keys: :atoms))
    state
  end

  defp handle_resp({_cmd, from}, msg, state) do
    GenServer.reply(from, msg |> to_string() |> String.strip() |> parse_resp())
    state
  end

  defp parse_resp("OK"), do: :ok
  defp parse_resp(msg), do: {:error, msg}
end
