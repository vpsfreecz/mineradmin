defmodule MinerAdmin.Api.Node.Delete do
  use HaveAPI.Action.Delete
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  def authorize(_req, user), do: Api.Authorize.admin(user)

  def exec(req) do
    case find(req.params[:node_id]) do
      nil ->
        {:error, "Object not found"}

      node ->
        delete(node)
    end
  end

  def find(id), do: Base.Query.Node.get(id)

  def delete(node) do
    case Base.Query.Node.delete(node) do
      {:ok, _} ->
        :ok

      {:error, changeset} ->
        Api.format_errors(changeset)
    end
  end
end
