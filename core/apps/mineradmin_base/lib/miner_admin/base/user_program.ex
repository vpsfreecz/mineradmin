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
    case Base.Program.can_start?(user_prog) do
      true ->
        {:ok, user_prog} = Base.Query.UserProgram.activate(user_prog, true)
        Miner.Dispatcher.start(user_prog)

      {:error, msg} ->
        {:error, msg}
    end
  end

  def stop(user_prog) do
    {:ok, user_prog} = Base.Query.UserProgram.activate(user_prog, false)
    Miner.Dispatcher.stop(user_prog)
  end

  def node_name(user_prog) do
    :"#{user_prog.node.name}@#{user_prog.node.domain}"
  end

  def arguments(cmdline) when is_binary(cmdline) do
    ~r{[^\s"']+|"([^"]*)"|'([^']*)'}
    |> Regex.scan(cmdline)
    |> Enum.map(fn
      [arg] when is_binary(arg) -> arg
      [with_quotes, without_quotes] -> without_quotes
    end)
  end

  def arguments(user_prog), do: arguments(user_prog.cmdline || "")

  def has_gpus?(user_prog) do
    Base.Query.UserProgram.gpus_count(user_prog.id) > 0
  end
end
