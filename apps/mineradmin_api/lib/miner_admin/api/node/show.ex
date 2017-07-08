defmodule MinerAdmin.Api.Node.Show do
  use HaveAPI.Action.Show
  alias MinerAdmin.Api
  alias MinerAdmin.Model

  auth false

  output do
    use Api.Node.Params
  end

  def item(req), do: Model.Query.Node.get(req.params[:node_id])
end
