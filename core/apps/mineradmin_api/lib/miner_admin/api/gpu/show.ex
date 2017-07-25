defmodule MinerAdmin.Api.Gpu.Show do
  use HaveAPI.Action.Show
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  output do
    use Api.Gpu.Params
  end

  def authorize(_req, _user), do: :allow

  def item(req) do
    req.params[:gpu_id]
    |> Base.Query.Gpu.get(req.user)
    |> Api.resourcify([:user, :node])
  end
end
