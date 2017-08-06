defmodule MinerAdmin.Api.UserProgram.Stop do
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
        case Base.UserProgram.stop(user_prog, req.user) do
          :ok ->
            :ok

          {:error, msg} ->
            {:error, msg}

          {:error, msg, opts} ->
            {:error, msg, opts}
        end
    end
  end

  defp find(id, user), do: Base.Query.UserProgram.get(id, user)
end
