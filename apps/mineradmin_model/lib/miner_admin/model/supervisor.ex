defmodule MinerAdmin.Model.Supervisor do
  use Supervisor
  alias MinerAdmin.Model

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = [
      supervisor(Model.UserSession.Supervisor, []),
      supervisor(Model.AuthBackend.Supervisor, []),
    ]

    supervise(children, strategy: :one_for_one)
  end
end