defmodule MinerAdmin.Api.User.Index do
  use HaveAPI.Action.Index
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  output do
    use Api.User.Params
  end

  def authorize(_req, session), do: Api.Authorize.admin(session)

  def items(req) do
    req.input
    |> Api.paginable()
    |> Base.Query.User.all()
    |> Api.resourcify([:auth_backend])
  end

  def count(_req), do: Base.Query.User.count
end
