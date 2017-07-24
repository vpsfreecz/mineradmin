defmodule MinerAdmin.Base.AuthBackend.Supervisor do
  use Supervisor
  alias MinerAdmin.Base

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    supervise(backend_workers(), strategy: :one_for_one, name: __MODULE__)
  end

  # TODO
  # def add_auth_backend

  defp backend_workers do
    import Supervisor.Spec

    Enum.reduce(
      Base.Query.AuthBackend.all,
      [],
      fn backend, acc ->
        [worker(
          Base.AuthBackend.Wrapper,
          [backend, [name: Base.AuthBackend.via_tuple(backend)]],
          id: backend.id
        ) | acc]
      end
    )
  end
end
