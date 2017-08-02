defmodule MinerAdmin.Api.Gpu.Index do
  use HaveAPI.Action.Index
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  output do
    use Api.Gpu.Params
  end

  def authorize(_req, _session), do: :allow

  def items(req) do
    Api.resourcify(Base.Query.Gpu.all(req.user.user), [:user, :node])
  end

  def count(req), do: Base.Query.Gpu.count(req.user.user)
end
