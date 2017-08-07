defmodule MinerAdmin.Api.AuthBackend.Show do
  use HaveAPI.Action.Show
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  output do
    use Api.AuthBackend.Params
  end

  def authorize(_req, session), do: Api.Authorize.admin(session)

  def find(req), do: Base.Query.AuthBackend.get(req.params[:authbackend_id])
  def check(req, _item), do: Base.User.admin?(req.user)
  def return(_req, item), do: item
end
