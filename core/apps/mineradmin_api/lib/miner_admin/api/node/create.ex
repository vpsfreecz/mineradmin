defmodule MinerAdmin.Api.Node.Create do
  use HaveAPI.Action.Create
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  input do
    use Api.Node.Params, only: [:name, :domain]
  end

  output do
    use Api.Node.Params
  end

  def authorize(_req, session), do: Api.Authorize.admin(session)

  def exec(req) do
    case Base.Query.Node.create(req.input) do
      {:ok, node} ->
        node

      {:error, changeset} ->
        Api.format_errors(changeset)
    end
  end
end
