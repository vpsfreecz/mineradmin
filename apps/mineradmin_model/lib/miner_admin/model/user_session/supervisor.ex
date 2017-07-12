defmodule MinerAdmin.Model.UserSession.Supervisor do
  use Supervisor
  alias MinerAdmin.Model

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: :user_session_supervisor)
  end

  def init([]) do
    supervise([], strategy: :one_for_one)
  end

  def add_session(session) do
    Supervisor.start_child(
      :user_session_supervisor,
      worker(
        Model.UserSession,
        [session, [name: Model.UserSession.via_tuple(session)]],
        restart: :transient,
        id: session.id
      )
    )
  end
end
