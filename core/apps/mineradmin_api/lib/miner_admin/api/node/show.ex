defmodule MinerAdmin.Api.Node.Show do
  use HaveAPI.Action.Show
  alias MinerAdmin.Api
  alias MinerAdmin.Model

  output do
    use Api.Node.Params
  end

  def authorize(_req, user), do: Model.User.admin?(user)

  def item(req), do: Model.Query.Node.get(req.params[:node_id])
end
