defmodule MinerAdmin.Model.UserSession do
  use GenServer

  require Logger
  alias MinerAdmin.Model
  alias MinerAdmin.Model.Query

  # Client API
  def start_link(session, opts) do
    GenServer.start_link(__MODULE__, session, opts)
  end

  def open(conn, user, [token: token]) do
    {:ok, session} = new(conn, user, :token)
      |> Map.merge(%{auth_token_id: token.id, auth_token_str: token.token})
      |> Query.UserSession.create()

    Model.UserSession.Supervisor.add_session(session)
    {:ok, session}
  end

  def continue(session) do
    :ok = GenServer.call(via_tuple(session), :continue)
  end

  def extend(session) do
    GenServer.call(via_tuple(session), :extend)
  end

  def close(session) do
    :ok = GenServer.call(via_tuple(session), :close)
  end

  def one_time(conn, user, :basic) do
    new(conn, user, :basic)
    |> Query.UserSession.one_time()
  end

  def find([token: token_str]) do
    case Query.AuthToken.find(token_str) do
      nil ->
        nil

      t ->
        Query.UserSession.find(token: t)
    end
  end

  def via_tuple(session) do
    {:via, Registry, {Model.Registry, {:user_session, session.id}}}
  end

  def valid_to(%Model.Schema.UserSession{auth_method: "basic"}) do
    :closed
  end

  def valid_to(%Model.Schema.UserSession{auth_method: "token"} = session) do
    session = Model.Repo.preload(session, [:auth_token])
    case session.auth_token.lifetime do
      :permanent ->
        :infinity

      _ ->
        session.auth_token.valid_to
    end
  end

  defp new(conn, user, method) do
    %{
      user_id: user.id,
      auth_method: to_string(method),
      opened_at: DateTime.utc_now,
      last_request_at: DateTime.utc_now,
      client_ip_addr: conn.remote_ip |> Tuple.to_list |> Enum.join("."),
      request_count: 1
    }
  end
  
  # Server implementation
  def init(session) do
    GenServer.cast(self(), :startup)
    {:ok, session}
  end

  def handle_cast(:startup, session) do
    return_cast(session)
  end
  
  def handle_call(:continue, _from, session) do
    {:ok, session} = Query.UserSession.update(session, %{
      last_request_at: DateTime.utc_now,
      request_count: session.request_count + 1
    })

    case session.auth_method do
      "token" ->
        Model.AuthToken.used(session.auth_token)

      _ ->
        nil
    end

    return_call(session)
  end
  
  def handle_call(:extend, _from, session) do
    case session.auth_method do
      "token" -> 
        return_call(session, Query.AuthToken.extend(session.auth_token))

      _ ->
        {:stop, :error}
    end
  end
  
  def handle_call(:close, _from, session) do
    {:stop, :normal, :ok, do_close(session)}
  end

  def handle_info(:timeout, session) do
    Logger.debug "Expiring session #{session.id}"
    {:stop, :normal, do_close(session)}
  end

  defp do_close(session) do
    common = %{
      last_request_at: DateTime.utc_now,
      request_count: session.request_count + 1,
      closed_at: DateTime.utc_now
    }

    {:ok, session} = Query.UserSession.close(session, common)
    session
  end

  defp return_cast(session), do: return(session, [:noreply, session]) 

  defp return_call(session), do: return_call(session, :ok)

  defp return_call(session, ret) do
    return(session, [:reply, ret, session])
  end

  defp return(session, ret) do
    case valid_to(session) do
      :infinity ->
        List.to_tuple(ret)

      valid_to ->
        timeout = Timex.diff(valid_to, DateTime.utc_now, :seconds)

        if timeout > 0 do
          List.to_tuple(ret ++ [timeout * 1000])

        else
          do_close(session)
          {:stop, :normal, session}
        end
    end
  end
end
