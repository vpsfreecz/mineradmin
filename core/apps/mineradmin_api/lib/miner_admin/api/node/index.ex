defmodule MinerAdmin.Api.Node.Index do
  use HaveAPI.Action.Index
  alias MinerAdmin.Api
  alias MinerAdmin.Model

  output do
    use Api.Node.Params
  end

  def authorize(_req, user), do: Model.User.admin?(user)

  def items(_req), do: Model.Query.Node.all

  def count(_req), do: Model.Query.Node.count
end
