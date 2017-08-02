defmodule MinerAdmin.Base.Program.Ethminer do
  alias MinerAdmin.Base
  alias MinerAdmin.Miner

  @behaviour Base.Program

  def changeset(changeset, _type) do
    Base.UserProgram.exclude_arguments(changeset, ~w(
      --cuda-devices
      -G --opencl
      -X --cuda-opencl
      --opencl-device --opencl-devices
      -t --mining-threads
      --list-devices
    ))
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

    {"ethminer", args ++ ["-U", "--cuda-devices"] ++ gpus}
  end

  def read_only?(_user_prog), do: true
end
