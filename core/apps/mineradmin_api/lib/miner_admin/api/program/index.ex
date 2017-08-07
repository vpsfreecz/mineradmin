defmodule MinerAdmin.Api.Program.Index do
  use HaveAPI.Action.Index
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  output do
    use Api.Program.Params
  end

  def authorize(_req, _session), do: :allow

  def items(req) do
    req.input
    |> Api.paginable()
    |> Base.Query.Program.all()
  end

  def count(_req), do: Base.Query.Program.count
end
