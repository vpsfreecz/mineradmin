defmodule MinerAdmin.Control.UserProgram do
  alias MinerAdmin.Base
  alias MinerAdmin.Control

  def create(params) do
    case Base.Query.UserProgram.create(params) do
      {:ok, user_prog} ->
        {:ok, _child} = Control.Dispatcher.create(user_prog)
        {:ok, user_prog}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def delete(user_prog) do
    Control.Dispatcher.remove(user_prog)
    Base.Query.UserProgram.delete(user_prog)
  end

  def start(user_prog, session) do
    case Base.Program.can_start?(user_prog) do
      true ->
        {:ok, user_prog} = Base.Query.UserProgram.activate(user_prog, true)
        Control.Dispatcher.start(user_prog, session)

      {:error, msg} ->
        {:error, msg}
    end
  end

  def stop(user_prog, session) do
    {:ok, user_prog} = Base.Query.UserProgram.activate(user_prog, false)
    Control.Dispatcher.stop(user_prog, session)
  end

  def restart(user_prog, session) do
    with true <- Base.Program.can_start?(user_prog),
         {:ok, user_prog} <- Base.Query.UserProgram.activate(user_prog, true),
         :ok <- ensure_stopped(user_prog, session),
         :ok <- Control.Dispatcher.start(user_prog, session) do
      :ok

    else
      {:error, msg} ->
        {:error, msg}
    end
  end

  def ensure_stopped(user_prog, session) do
    case Control.Dispatcher.stop(user_prog, session) do
      :ok -> :ok
      :not_started -> :ok
      other -> other
    end
  end
end
