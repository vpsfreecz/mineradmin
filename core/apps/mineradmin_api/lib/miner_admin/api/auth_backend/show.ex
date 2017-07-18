defmodule MinerAdmin.Api.AuthBackend.Show do
  use HaveAPI.Action.Show
  alias MinerAdmin.Api
  alias MinerAdmin.Model

  output do
    use Api.AuthBackend.Params
  end

  def authorize(_req, user), do: Model.User.admin?(user)

  def item(req), do: Model.Query.AuthBackend.get(req.params[:authbackend_id])
end
