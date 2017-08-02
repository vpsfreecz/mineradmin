defmodule MinerAdmin.Api.UserProgram.WebSocket do
  require Logger
  alias Plug.Conn
  alias MinerAdmin.Base
  alias MinerAdmin.Miner

  @behaviour :cowboy_websocket_handler
  @connection Plug.Adapters.Cowboy.Conn
  @timeout :infinity

  def init(_type, _req, opts) do
    unless Keyword.has_key?(opts, :auth_chain) do
      raise "missing option auth_chain"
    end

    {:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_init(type, req, opts) do
    conn = @connection.conn(req, type) |> Conn.fetch_query_params()

    with {:ok, conn, session} <- authenticated?(conn, opts[:auth_chain]),
         {:ok, user_prog} <- user_program(conn.params["user_program"], session.user),
         true <- authorized?(session.user, user_prog),
         {:ok, worker, accessor} <- subscribe(user_prog) do

      Process.monitor(worker)
      Base.UserProgramLog.log(user_prog, session, :attach, nil)
      {
        :ok,
        req,
        %{conn: conn, user_prog: user_prog, session: session, accessor: accessor},
        @timeout
      }

    else
      _ ->
        {:shutdown, req}
    end
  end

  def websocket_handle({:text, "W " <> data}, req, state) do
    unless Base.Program.read_only?(state.user_prog) do
      state.accessor.write.(String.strip(data))
    end

    {:ok, req, state}
  end

  def websocket_handle({:text, "S " <> data}, req, state) do
    [w, h] = data |> String.strip |> String.split(" ")
    state.accessor.resize.(w, h)
    {:ok, req, state}
  end

  def websocket_info({:user_program, :output, data}, req, state) do
    {:reply, {:text, data}, req, state}
  end

  def websocket_info({:DOWN, _ref, :process, _pid, reason}, req, state) do
    Logger.debug "Miner worker has exited with #{reason}, closing socket"
    {:shutdown, req, state}
  end

  def websocket_info(_other, req, state) do
    {:ok, req, state}
  end

  def websocket_terminate(_reason, _req, state) do
    Base.UserProgramLog.log(state.user_prog, state.session, :detach, nil)
    :ok
  end

  defp authenticated?(conn, chain) do
    conn = HaveAPI.Authentication.Chain.authenticate(conn, chain: chain)

    case HaveAPI.Authentication.user(conn) do
      nil -> false
      user -> {:ok, conn, user}
    end
  end

  defp user_program(id, user) do
    case Base.Query.UserProgram.get(id, user) do
      nil ->
        {:error, "not found"}

      user_prog ->
        {:ok, user_prog}
    end
  end

  defp authorized?(user, user_prog) do
    Base.User.admin?(user) || user_prog.user_id == user.id
  end

  defp subscribe(user_prog) do
    Miner.Dispatcher.attach(user_prog, self())
  end
end
