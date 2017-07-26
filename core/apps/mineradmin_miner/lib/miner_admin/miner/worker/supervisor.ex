defmodule MinerAdmin.Miner.Worker.Supervisor do
  use Supervisor
  alias MinerAdmin.Miner
  alias MinerAdmin.Base

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    supervise(workers(), strategy: :one_for_one)
  end

  def add_program(user_prog) do
    Supervisor.start_child(__MODULE__, worker_spec(user_prog))
  end

  defp workers do
    for user_prog <- Base.Query.UserProgram.on_node(Node.self) do
      worker_spec(user_prog)
    end
  end

  defp worker_spec(user_prog) do
    worker(
      Miner.Worker,
      [user_prog, [name: Miner.Worker.via_tuple(user_prog)]],
      restart: :transient,
      id: user_prog.id
    )
  end
end
