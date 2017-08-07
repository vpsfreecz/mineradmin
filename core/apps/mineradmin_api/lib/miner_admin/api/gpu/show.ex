defmodule MinerAdmin.Api.Gpu.Show do
  use HaveAPI.Action.Show
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  output do
    use Api.Gpu.Params
  end

  def authorize(_req, _session), do: :allow
  def find(req), do: Base.Query.Gpu.get(req.params[:gpu_id], req.user.user)
  def check(req, item), do: Base.User.admin?(req.user) || item.user_id == req.user.user_id
  def return(_req, item), do: Api.resourcify(item, [:user, :node])
end
