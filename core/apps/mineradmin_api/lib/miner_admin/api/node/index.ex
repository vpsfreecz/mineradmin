defmodule MinerAdmin.Api.Node.Index do
  use HaveAPI.Action.Index
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  output do
    use Api.Node.Params
  end

  def authorize(req, _session), do: :allow

  def items(req) do
    req.input
    |> Api.paginable()
    |> Base.Query.Node.all()
    |> Api.Node.resources()
  end

  def count(_req), do: Base.Query.Node.count
end
