defmodule MinerAdmin.Model.UserSession.Starter do
  require Logger
  use GenServer
  alias MinerAdmin.Model

  def start_link do
    GenServer.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    GenServer.cast(self(), :init)

    {:ok, nil}
  end

  def handle_cast(:init, nil) do
    Logger.debug "Starting user session processes"

    for s <- Model.Query.UserSession.active_sessions() do
      Logger.debug "Session #{s.id}"

      Model.UserSession.WorkerSupervisor.add_session(s)
    end

    {:stop, :normal, nil}
  end
end
