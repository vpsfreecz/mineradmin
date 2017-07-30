defmodule MinerAdmin.Api.UserProgram.Index do
  use HaveAPI.Action.Index
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  output do
    use Api.UserProgram.Params
  end

  def authorize(_req, _user), do: :allow

  def items(req) do
    Api.resourcify(Base.Query.UserProgram.all(req.user), [:user, :program, :node])
  end

  def count(req), do: Base.Query.UserProgram.count(req.user)
end
