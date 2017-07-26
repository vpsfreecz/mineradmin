defmodule MinerAdmin.Api.UserProgram.Start do
  use HaveAPI.Action

  alias MinerAdmin.Base

  method :post
  route ":%{resource}_id/%{action}"

  def authorize(_req, _user), do: :allow

  def exec(req) do
    case find(req.params[:userprogram_id], req.user) do
      nil->
        {:error, "Object not found"}

      user_prog ->
        Base.UserProgram.start(user_prog)
        :ok
    end
  end

  defp find(id, user), do: Base.Query.UserProgram.get(id, user)
end
