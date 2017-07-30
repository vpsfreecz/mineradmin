defmodule MinerAdmin.Api.AuthBackend.Index do
  use HaveAPI.Action.Index
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  output do
    use Api.AuthBackend.Params
  end

  def authorize(_req, user), do: Api.Authorize.admin(user)

  def items(_req), do: Base.Query.AuthBackend.all

  def count(_req), do: Base.Query.AuthBackend.count
end
