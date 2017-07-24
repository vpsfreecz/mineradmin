defmodule MinerAdmin.Api.AuthBackend.Show do
  use HaveAPI.Action.Show
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  output do
    use Api.AuthBackend.Params
  end

  def authorize(_req, user), do: Base.User.admin?(user)

  def item(req), do: Base.Query.AuthBackend.get(req.params[:authbackend_id])
end
