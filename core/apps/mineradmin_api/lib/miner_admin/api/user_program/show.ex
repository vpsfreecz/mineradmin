defmodule MinerAdmin.Api.UserProgram.Show do
  use HaveAPI.Action.Show
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  output do
    use Api.UserProgram.Params
  end

  def authorize(_req, _session), do: :allow

  def find(req), do: Base.Query.UserProgram.get(req.params[:userprogram_id], req.user.user)
  def check(req, item), do: Base.User.admin?(req.user) || req.user.user_id == item.user_id
  def return(_req, item) do
    item
    |> Api.UserProgram.resource()
    |> Api.resourcify([:user, :program, :node])
  end
end
