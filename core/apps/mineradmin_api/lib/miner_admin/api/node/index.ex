defmodule MinerAdmin.Api.Node.Index do
  use HaveAPI.Action.Index
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  output do
    use Api.Node.Params
  end

  def authorize(_req, user), do: Base.User.admin?(user)

  def items(_req), do: Base.Query.Node.all

  def count(_req), do: Base.Query.Node.count
end
