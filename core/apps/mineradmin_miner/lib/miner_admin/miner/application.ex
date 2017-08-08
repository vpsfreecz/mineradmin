defmodule MinerAdmin.Miner.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias MinerAdmin.Miner

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: MinerAdmin.Miner.Worker.start_link(arg1, arg2, arg3)
      # worker(MinerAdmin.Miner.Worker, [arg1, arg2, arg3]),
      supervisor(Registry, [:unique, Miner.Registry]),
      worker(Miner.Probe, [], restart: :transient),
      supervisor(Miner.Nvidia.Supervisor, []),
      supervisor(Miner.Worker.Supervisor, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :rest_for_one, name: Miner.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
