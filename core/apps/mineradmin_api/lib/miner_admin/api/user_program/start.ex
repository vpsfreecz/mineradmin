defmodule MinerAdmin.Api.UserProgram.Start do
  use HaveAPI.Action

  alias MinerAdmin.Base

  method :post
  route ":%{resource}_id/%{action}"

  def authorize(_req, _session), do: :allow

  def exec(req) do
    case find(req.params[:userprogram_id], req.user.user) do
      nil->
        {:error, "Object not found"}

      user_prog ->
        case Base.UserProgram.start(user_prog) do
          {:error, msg} ->
            {:error, msg}

          _ ->
            :ok
        end
    end
  end

  defp find(id, user), do: Base.Query.UserProgram.get(id, user)
end
