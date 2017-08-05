defmodule MinerAdmin.Base.UserProgram do
  import Kernel, except: [node: 1]
  alias MinerAdmin.Base
  alias MinerAdmin.Miner

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
end
