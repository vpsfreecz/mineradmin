defmodule MinerAdmin.Miner.Probe do
  use GenServer
  alias MinerAdmin.Miner

  # Client API
  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  # Server implementation
  def init([]) do
    GenServer.cast(self(), :startup)
    {:ok, nil}
  end

  def handle_cast(:startup, nil) do
    Miner.Nvidia.probe

    {:stop, :normal, nil}
  end
end
