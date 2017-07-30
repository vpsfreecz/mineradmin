defmodule MinerAdmin.Api.Node.Update do
  use HaveAPI.Action.Update
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  input do
    use Api.Node.Params, only: [:name, :domain]
  end

  output do
    use Api.Node.Params
  end

  def authorize(_req, user), do: Api.Authorize.admin(user)

  def exec(req) do
    case find(req.params[:node_id]) do
      nil ->
        {:error, "Object not found"}

      node ->
        update(node, req.input)
    end
  end

  def find(id), do: Base.Query.Node.get(id)

  def update(node, params) do
    case Base.Query.Node.update(node, params) do
      {:ok, node} ->
        node

      {:error, changeset} ->
        Api.format_errors(changeset)
    end
  end
end
