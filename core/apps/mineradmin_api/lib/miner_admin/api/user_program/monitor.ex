defmodule MinerAdmin.Api.UserProgram.Monitor do
  use GenServer

  require Logger
  alias MinerAdmin.Base

  @table __MODULE__

  # Client API
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def running?(user_prog) do
    cached(user_prog) || GenServer.call(__MODULE__, {:monitor, user_prog})
  end

  defp cached(user_prog) do
    key = user_prog.id

    case :ets.lookup(@table, user_prog.id) do
      [{^key, status}] -> status
      _ -> nil
    end
  end

  # Server implementation
  def init([]) do
    :ets.new(@table, [:named_table])
    {:ok, %{}}
  end

  def handle_call({:monitor, user_prog}, _from, state) do
    case cached(user_prog) do
      nil -> monitor(user_prog, state)
      status -> {:reply, status, state}
    end
  end

  def handle_info({:user_program, :monitor, user_prog_id, status}, state) do
    :ets.insert(@table, {user_prog_id, status})
    {:noreply, state}
  end

  def handle_info({:DOWN, ref, :process, _pid, reason}, state) do
    Logger.debug "Monitored worker exited with #{reason}"
    :ets.delete(@table, state[ref])
    {:noreply, Map.delete(state, ref)}
  end

  defp monitor(user_prog, state) do
    case Base.UserProgram.monitor(user_prog, self()) do
      {:badrpc, _reason} ->
        {:reply, false, state}

      {worker, status} ->
        :ets.insert(@table, {user_prog.id, status})
        ref = Process.monitor(worker)
        {:reply, status, Map.put(state, ref, user_prog.id)}
    end
  end
end
