defmodule MinerAdmin.Api.UserProgram.Log.Index do
  use HaveAPI.Action.Index
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  output do
    use Api.UserProgram.Log.Params
  end

  def authorize(_req, _session), do: :allow

  def items(req) do
    case find(req.params[:userprogram_id], req.user.user) do
      nil ->
        {:error, "UserProgram not found", http_status: 404}

      user_prog ->
        Base.Query.UserProgramLog.all(user_prog)
    end
  end

  def count(req) do
    Base.Query.UserProgramLog.count(req.params[:userprogram_id])
  end

  defp find(id, user) do
    Base.Query.UserProgram.get(id, user)
  end
end
