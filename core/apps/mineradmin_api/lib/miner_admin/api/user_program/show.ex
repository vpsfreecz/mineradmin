defmodule MinerAdmin.Api.UserProgram.Show do
  use HaveAPI.Action.Show
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  output do
    use Api.UserProgram.Params
  end

  def authorize(_req, _session), do: :allow

  def item(req) do
    req.params[:userprogram_id]
    |> Base.Query.UserProgram.get(req.user.user)
    |> Api.UserProgram.resource()
    |> Api.resourcify([:user, :program, :node])
  end
end
