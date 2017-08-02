defmodule MinerAdmin.Api.AuthBackend.Index do
  use HaveAPI.Action.Index
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  output do
    use Api.AuthBackend.Params
  end

  def authorize(_req, session), do: Api.Authorize.admin(session)

  def items(_req), do: Base.Query.AuthBackend.all

  def count(_req), do: Base.Query.AuthBackend.count
end
