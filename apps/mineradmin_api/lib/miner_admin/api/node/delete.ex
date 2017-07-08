defmodule MinerAdmin.Api.Node.Delete do
  use HaveAPI.Action.Delete
  alias MinerAdmin.Api
  alias MinerAdmin.Model

  auth false

  def exec(req) do
    case find(req.params[:node_id]) do
      nil ->
        {:error, "Object not found"}

      node ->
        delete(node)
    end
  end

  def find(id), do: Model.Query.Node.get(id)

  def delete(node) do
    case Model.Query.Node.delete(node) do
      {:ok, _} ->
        :ok

      {:error, changeset} ->
        {:error, "Validation failed", errors: Enum.map(
          changeset.errors, fn {k, {msg, _opts}} -> {k, [msg]} end
        ) |> Map.new}
    end
  end
end
