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

  def status(pid, id) do
    GenServer.call(pid, {:status, id})
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

  def write_encoded(pid, data) do
    GenServer.cast(pid, {:write_encoded, data})
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
    send_cmd(state.socket, :status)
    {:noreply, %{state | queue: :queue.in({:status, from}, state.queue)}}
  end

  def handle_call({:status, id}, from, state) do
    send_cmd(state.socket, :status, %{id: id})
    {:noreply, %{state | queue: :queue.in({{:status, id}, from}, state.queue)}}
  end

  def handle_call(:list, from, state) do
    send_cmd(state.socket, :list)
    {:noreply, %{state | queue: :queue.in({:list, from}, state.queue)}}
  end

  def handle_call({:start, id, cmd, args}, from, state) do
    send_cmd(state.socket, :start, %{id: id, cmd: cmd, args: args})
    {:noreply, %{state | queue: :queue.in({:start, from}, state.queue)}}
  end

  def handle_call({:stop, id}, from, state) do
    send_cmd(state.socket, :stop, %{id: id})
    {:noreply, %{state | queue: :queue.in({:stop, from}, state.queue)}}
  end

  def handle_call({:attach, id, receiver}, from, state) do
    send_cmd(state.socket, :attach, %{id: id})
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

  def handle_cast({:write_encoded, data}, %{mode: :attached} = state) do
    :gen_tcp.send(state.socket, "W #{data}\n")
    {:noreply, state}
  end

  def handle_cast({:resize, w, h}, %{mode: :attached} = state) do
    :gen_tcp.send(state.socket, "S #{w} #{h}\n")
    {:noreply, state}
  end

  def handle_info({:tcp, _socket, msg}, %{mode: :cmd} = state) do
    {{:value, item}, queue} = :queue.out(state.queue)
    {:noreply, handle_resp(item, decode(msg), %{state | queue: queue})}
  end

  def handle_info({:tcp, _socket, msg}, %{mode: :attached} = state) do
    send(state.receiver, {:minerd, self(), msg})
    {:noreply, state}
  end

  def handle_info({:tcp_closed, _socket}, state) do
    {:stop, :closed, state}
  end

  def handle_info({:tcp_error, _socket, reason}, state) do
    {:stop, reason, state}
  end

  defp send_cmd(socket, cmd, opts \\ %{}) do
    :gen_tcp.send(socket, Poison.encode!(%{
      cmd: cmd |> Atom.to_string() |> String.upcase(),
      opts: opts,
    }) <> "\n")
  end

  defp handle_resp({:attach, from}, %{status: true}, state) do
    GenServer.reply(from, :ok)

    :inet.setopts(state.socket, packet: :raw)
    %{state | mode: :attached}
  end

  defp handle_resp({:attach, from}, %{status: false} = msg, state) do
    GenServer.reply(from, {:error, msg.message})
    %{state | receiver: nil}
  end

  defp handle_resp({{:status, _id}, from}, %{status: false} = msg, state) do
    GenServer.reply(from, {:error, msg.message})
    state
  end

  defp handle_resp({{:status, _id}, from}, msg, state) do
    GenServer.reply(from, msg.response)
    state
  end

  defp handle_resp({:list, from}, msg, state) do
    GenServer.reply(from, msg.response)
    state
  end

  defp handle_resp({_cmd, from}, %{status: true}, state) do
    GenServer.reply(from, :ok)
    state
  end

  defp handle_resp({_cmd, from}, %{status: false} = msg, state) do
    GenServer.reply(from, {:error, msg.message})
    state
  end

  defp decode(msg) do
    msg
    |> to_string()
    |> String.strip()
    |> Poison.decode!(keys: :atoms)
  end
end
