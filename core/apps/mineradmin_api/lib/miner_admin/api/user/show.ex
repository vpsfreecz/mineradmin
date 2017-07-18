defmodule MinerAdmin.Api.User.Show do
  use HaveAPI.Action.Show
  alias MinerAdmin.Api
  alias MinerAdmin.Model

  output do
    use Api.User.Params
  end

  def authorize(_req, user), do: Model.User.admin?(user)

  def item(req) do
    Api.resourcify(Model.Query.User.get(req.params[:user_id]), [:auth_backend])
  end
end
