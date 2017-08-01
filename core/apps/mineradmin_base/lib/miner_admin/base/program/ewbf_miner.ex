defmodule MinerAdmin.Base.Program.EwbfMiner do
  alias MinerAdmin.Base
  alias MinerAdmin.Miner

  @behaviour Base.Program

  def changeset(changeset, _type) do
    Ecto.Changeset.validate_change(changeset, :cmdline, fn :cmdline, cmdline ->
      args = Base.UserProgram.arguments(cmdline)
      errors = Enum.reduce(
        ~w(--cuda_devices --api),
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

  def can_start?(user_prog) do
    if Base.UserProgram.has_gpus?(user_prog) do
      true

    else
      {:error, "Assign one or more GPUs"}
    end
  end

  def command(user_prog) do
    args = user_prog
      |> Base.UserProgram.arguments()

    gpus = user_prog
      |> Base.Query.UserProgram.gpus()
      |> Enum.map(&(&1.uuid))
      |> Miner.GpuMapper.uuids_to_indexes()
      |> Enum.map(&to_string/1)

    {"ewbf-miner", args ++ ["--cuda_devices"] ++ gpus}
  end
end
