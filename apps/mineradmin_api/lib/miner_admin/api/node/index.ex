defmodule MinerAdmin.Api.Node.Index do
  use HaveAPI.Action.Index
  alias MinerAdmin.Api
  alias MinerAdmin.Model

  auth false

  output do
    use Api.Node.Params
  end

  def items(_req), do: Model.Query.Node.all

  def count(_req), do: Model.Query.Node.count
end
