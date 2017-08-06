defmodule MinerAdmin.Miner.Dispatcher do
  @moduledoc """
  The dispatcher is a module present on every worker node. It receives commands
  from the api/base/model to manage running programs on a particular node.
  """
  alias MinerAdmin.Base
  alias MinerAdmin.Miner

  def create(user_prog) do
    IO.puts "starting worker"
    ret = Miner.Worker.Supervisor.add_program(user_prog)

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
    Miner.Worker.remove(user_prog)
    :ok
  end

  def start(user_prog, session) do
    Miner.Worker.start(user_prog, session)
  end

  def stop(user_prog, session) do
    Miner.Worker.stop(user_prog, session)
  end

  def attach(user_prog, receiver) do
    Miner.Worker.attach(user_prog, receiver)
  end

  def running?(user_prog) do
    Miner.Worker.running?(user_prog)
  end

  def monitor(user_prog, receiver) do
    Miner.Worker.monitor(user_prog, receiver)
  end
end
