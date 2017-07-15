defmodule MinerAdmin.Model.UserSession.Supervisor do
  use Supervisor
  alias MinerAdmin.Model

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = [
      supervisor(Model.UserSession.WorkerSupervisor, []),
      worker(Model.UserSession.Starter, [], restart: :transient),
    ]

    supervise(children, strategy: :rest_for_one, name: __MODULE__)
  end
end
