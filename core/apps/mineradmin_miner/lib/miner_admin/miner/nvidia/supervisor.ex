defmodule MinerAdmin.Miner.Nvidia.Supervisor do
  use Supervisor
  alias MinerAdmin.Miner

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    workers = [
      worker(Miner.Nvidia.GpuMapper, []),
    ]

    supervise(workers, strategy: :one_for_one)
  end
end
