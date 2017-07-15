defmodule MinerAdmin.Model.AuthBackend.Supervisor do
  use Supervisor
  alias MinerAdmin.Model

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
      Model.Query.AuthBackend.all,
      [],
      fn backend, acc ->
        [worker(
          Model.AuthBackend.Wrapper,
          [backend, [name: Model.AuthBackend.via_tuple(backend)]],
          id: backend.id
        ) | acc]
      end
    )
  end
end
