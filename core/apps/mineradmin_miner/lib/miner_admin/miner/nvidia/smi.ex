defmodule MinerAdmin.Miner.Nvidia.Smi do
  def query(fields) do
    {list, 0} = System.cmd(
      "nvidia-smi",
      ["--query-gpus=#{Enum.join(fields, ",")}", "--format=csv,noheader"]
    )

    list
    |> String.strip
    |> String.split("\n")
    |> Enum.map(fn line ->
         line
         |> String.split(",")
         |> Enum.map(&String.strip/1)
       end)
  end
end
