defmodule MinerAdmin.Api.User.Index do
  use HaveAPI.Action.Index
  alias MinerAdmin.Api
  alias MinerAdmin.Model

  output do
    use Api.User.Params
  end

  def authorize(_req, user), do: Model.User.admin?(user)

  def items(_req) do
    Api.resourcify(Model.Query.User.all, [:auth_backend])
  end

  def count(_req), do: Model.Query.User.count
end
