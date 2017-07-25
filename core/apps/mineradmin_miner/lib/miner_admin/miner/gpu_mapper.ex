defmodule MinerAdmin.Miner.GpuMapper do
  use GenServer
  alias MinerAdmin.Miner

  # Client API
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def uuid_to_index(uuid) do
    GenServer.call(__MODULE__, {:uuid_to_index, uuid})
  end

  # Server implementation
  def init([]) do
    GenServer.cast(self(), :startup)
    {:ok, %{}}
  end

  def handle_cast(:startup, %{}) do
    map = ~w(uuid index)
      |> Miner.Nvidia.Smi.query()
      |> Enum.map(fn [uuid, index] -> {uuid, String.to_integer(index)} end)
      |> Enum.into(%{})

    {:noreply, map}
  end

  def handle_call({:uuid_to_index, uuid}, _from, state) do
    {:reply, state[uuid], state}
  end
end
