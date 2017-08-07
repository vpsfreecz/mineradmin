defmodule MinerAdmin.Api.Node.Show do
  use HaveAPI.Action.Show
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  output do
    use Api.Node.Params
  end

  def authorize(_req, _session), do: :allow

  def find(req), do: Base.Query.Node.get(req.params[:node_id])
  def check(_req, _item), do: true
  def return(_req, item), do: Api.Node.resource(item)
end
