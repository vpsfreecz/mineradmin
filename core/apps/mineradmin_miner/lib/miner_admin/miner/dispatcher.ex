defmodule MinerAdmin.Miner.Dispatcher do
  @moduledoc """
  The dispatcher is a process running on every worker node. It receives commands
  from the api/base/model to manage running programs on a particular node.
  """
  use GenServer

  alias MinerAdmin.Base
  alias MinerAdmin.Miner

  # Client API
  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def create(user_prog) do
    IO.puts "starting worker"
    ret = GenServer.call(
      {__MODULE__, Base.UserProgram.node_name(user_prog)},
      {:create, user_prog}
    )

    case ret do
      {:ok, child} ->
        {:ok, child}

      {:ok, child, _info} ->
        {:ok, child}

      other ->
        other
    end
  end

  def remove(user_prog) do
    IO.puts "removing worker"
    GenServer.call(
      {__MODULE__, Base.UserProgram.node_name(user_prog)},
      {:remove, user_prog}
    )
    :ok
  end

  def start(user_prog) do
    GenServer.call(
      {__MODULE__, Base.UserProgram.node_name(user_prog)},
      {:start, user_prog}
    )
  end

  def stop(user_prog) do
    GenServer.call(
      {__MODULE__, Base.UserProgram.node_name(user_prog)},
      {:stop, user_prog}
    )
  end

  def attach(user_prog, receiver) do
    GenServer.call(
      {__MODULE__, Base.UserProgram.node_name(user_prog)},
      {:attach, user_prog, receiver}
    )
  end

  # Server implementation
  def init(nil) do
    {:ok, nil}
  end

  def handle_call({:create, user_prog}, _from, nil) do
    {:reply, Miner.Worker.Supervisor.add_program(user_prog), nil}
  end

  def handle_call({:remove, user_prog}, _from, nil) do
    {:reply, Miner.Worker.remove(user_prog), nil}
  end

  def handle_call({:start, user_prog}, _from, nil) do
    {:reply, Miner.Worker.start(user_prog), nil}
  end

  def handle_call({:stop, user_prog}, _from, nil) do
    {:reply, Miner.Worker.stop(user_prog), nil}
  end

  def handle_call({:attach, user_prog, receiver}, _from, nil) do
    {:reply, Miner.Worker.attach(user_prog, receiver), nil}
  end
end
