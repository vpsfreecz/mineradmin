defmodule MinerAdmin.Base.UserProgram do
  import Kernel, except: [node: 1]
  alias MinerAdmin.Base

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

  def exclude_arguments(changeset, exclude) do
    Ecto.Changeset.validate_change(changeset, :cmdline, fn :cmdline, cmdline ->
      args = Base.UserProgram.arguments(cmdline)
      errors = Enum.reduce(
        exclude,
        [],
        fn v, acc ->
          if Enum.find(args, nil, &(&1 == v)) do
            ["must not contain option #{v}" | acc]
          else
            acc
          end
        end
      )

      if length(errors) > 0 do
        [cmdline: Enum.join(errors, "; ")]

      else
        []
      end
    end)
  end

  def create(params) do
    case Base.Query.UserProgram.create(params) do
      {:ok, user_prog} ->
        {:ok, _child} = call_worker(user_prog, :create, [user_prog])
        {:ok, user_prog}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def delete(user_prog) do
    call_worker(user_prog, :remove, [user_prog])
    Base.Query.UserProgram.delete(user_prog)
  end

  def start(user_prog, session) do
    case Base.Program.can_start?(user_prog) do
      true ->
        {:ok, user_prog} = Base.Query.UserProgram.activate(user_prog, true)
        call_worker(user_prog, :start, [user_prog, session])

      {:error, msg} ->
        {:error, msg}
    end
  end

  def stop(user_prog, session) do
    {:ok, user_prog} = Base.Query.UserProgram.activate(user_prog, false)
    call_worker(user_prog, :stop, [user_prog, session])
  end

  def restart(user_prog, session) do
    with true <- Base.Program.can_start?(user_prog),
         {:ok, user_prog} <- Base.Query.UserProgram.activate(user_prog, true),
         :ok <- ensure_stopped(user_prog, session),
         :ok <- call_worker(user_prog, :start, [user_prog, session]) do
      :ok

    else
      {:error, msg} ->
        {:error, msg}
    end
  end

  def ensure_stopped(user_prog, session) do
    case call_worker(user_prog, :stop, [user_prog, session]) do
      :ok -> :ok
      :not_started -> :ok
      other -> other
    end
  end

  def attach(user_prog, receiver) do
    call_worker(user_prog, :attach, [user_prog, receiver])
  end

  def running?(user_prog) do
    case call_worker(user_prog, :running?, [user_prog]) do
      status when is_boolean(status) -> status
      {:badrpc, _reason} -> false
    end
  end

  def monitor(user_prog, receiver) do
    call_worker(user_prog, :monitor, [user_prog, receiver])
  end

  defp call_worker(user_prog, func, args) do
    :rpc.call(node_name(user_prog), MinerAdmin.Miner.Dispatcher, func, args)
  end
end
