defmodule MinerAdmin.Api.Gpu.Index do
  use HaveAPI.Action.Index
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  output do
    use Api.Gpu.Params
  end

  def authorize(_req, _session), do: :allow

  def items(req) do
    req.user.user
    |> Base.Query.Gpu.all(Api.paginable(req.input))
    |> Api.resourcify([:user, :node])
  end

  def count(req), do: Base.Query.Gpu.count(req.user.user)
end
