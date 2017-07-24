defmodule MinerAdmin.Base.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias MinerAdmin.Base

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: MinerAdmin.Base.Worker.start_link(arg1, arg2, arg3)
      supervisor(Base.Repo, []),
      supervisor(Registry, [:unique, Base.Registry]),
      supervisor(Base.Supervisor, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :rest_for_one, name: :mineradmin_base_app_supervisor]
    Supervisor.start_link(children, opts)
  end
end
