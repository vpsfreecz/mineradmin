defmodule MinerAdmin.Api.AuthBackend.Index do
  use HaveAPI.Action.Index
  alias MinerAdmin.Api
  alias MinerAdmin.Model

  output do
    use Api.AuthBackend.Params
  end

  def authorize(_req, user), do: Model.User.admin?(user)

  def items(_req), do: Model.Query.AuthBackend.all

  def count(_req), do: Model.Query.AuthBackend.count
end
