defmodule MinerAdmin.Model.UserSession.Supervisor do
  use Supervisor
  alias MinerAdmin.Model
  require Logger

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    supervise(active_sessions(), strategy: :one_for_one, name: __MODULE__)
  end

  def add_session(session) do
    Supervisor.start_child(__MODULE__, worker_spec(session))
  end

  defp active_sessions do
    for s <- Model.Query.UserSession.active_sessions do
      Logger.debug "Monitoring user session #{s.id}"

      worker_spec(s)
    end
  end

  defp worker_spec(session) do
    worker(
      Model.UserSession,
      [session, [name: Model.UserSession.via_tuple(session)]],
      restart: :transient,
      id: session.id
    )
  end
end
