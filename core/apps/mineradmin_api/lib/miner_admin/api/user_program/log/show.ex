defmodule MinerAdmin.Api.UserProgram.Log.Show do
  use HaveAPI.Action.Show
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  output do
    use Api.UserProgram.Log.Params
  end

  def authorize(_req, _session), do: :allow

  def find(req) do
    case find_prog(req.params[:userprogram_id], req.user.user) do
      nil ->
        {:error, "UserProgram not found", http_status: 404}

      user_prog ->
        find_log(user_prog, req.params[:log_id])
    end
  end

  defp find_prog(id, user) do
    Base.Query.UserProgram.get(id, user)
  end

  defp find_log(user_prog, id) do
    case Base.Query.UserProgramLog.get(user_prog, id) do
      nil ->
        {:error, "Log not found", http_status: 404}

      log ->
        log
    end
  end
end
