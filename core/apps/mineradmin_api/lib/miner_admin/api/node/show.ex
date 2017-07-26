defmodule MinerAdmin.Api.Node.Show do
  use HaveAPI.Action.Show
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  output do
    use Api.Node.Params
  end

  def authorize(_req, user), do: :allow

  def item(req), do: Base.Query.Node.get(req.params[:node_id])
end
