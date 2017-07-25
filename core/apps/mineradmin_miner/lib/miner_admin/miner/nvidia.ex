defmodule MinerAdmin.Miner.Nvidia do
  alias __MODULE__
  alias MinerAdmin.Base.Query

  def probe do
    ~w(uuid name)
    |> Nvidia.Smi.query()
    |> Enum.map(fn [uuid, name] -> {uuid, %{name: name}} end)
    |> Query.Gpu.update_by_uuids(Node.self)
  end
end
