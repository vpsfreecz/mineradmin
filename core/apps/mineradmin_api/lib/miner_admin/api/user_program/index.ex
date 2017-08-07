defmodule MinerAdmin.Api.UserProgram.Index do
  use HaveAPI.Action.Index
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  output do
    use Api.UserProgram.Params
  end

  def authorize(_req, _session), do: :allow

  def items(req) do
    req.user.user
    |> Base.Query.UserProgram.all(Api.paginable(req.input))
    |> Api.UserProgram.resources()
    |> Api.resourcify([:user, :program, :node])
  end

  def count(req), do: Base.Query.UserProgram.count(req.user.user)
end
