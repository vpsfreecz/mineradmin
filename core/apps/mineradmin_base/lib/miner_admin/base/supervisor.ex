defmodule MinerAdmin.Base.Supervisor do
  use Supervisor
  alias MinerAdmin.Base

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = [
      supervisor(Base.AuthBackend.Supervisor, []),
    ]

    supervise(children, strategy: :one_for_one)
  end
end
