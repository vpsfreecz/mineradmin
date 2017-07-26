defmodule MinerAdmin.Base.UserProgram do
  import Kernel, except: [node: 1]
  alias MinerAdmin.Base
  alias MinerAdmin.Miner

  def create(params) do
    case Base.Query.UserProgram.create(params) do
      {:ok, user_prog} ->
        {:ok, _child} = Miner.Dispatcher.create(user_prog)
        {:ok, user_prog}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def delete(user_prog) do
    Miner.Dispatcher.remove(user_prog)
    Base.Query.UserProgram.delete(user_prog)
  end

  def start(user_prog) do
    {:ok, user_prog} = Base.Query.UserProgram.activate(user_prog, true)
    Miner.Dispatcher.start(user_prog)
  end

  def stop(user_prog) do
    {:ok, user_prog} = Base.Query.UserProgram.activate(user_prog, false)
    Miner.Dispatcher.stop(user_prog)
  end

  def node_name(user_prog) do
    :"#{user_prog.node.name}@#{user_prog.node.domain}"
  end
end
