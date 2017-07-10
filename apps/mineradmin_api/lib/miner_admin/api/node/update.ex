defmodule MinerAdmin.Api.Node.Update do
  use HaveAPI.Action.Update
  alias MinerAdmin.Api
  alias MinerAdmin.Model

  input do
    use Api.Node.Params, only: [:name, :domain]
  end

  output do
    use Api.Node.Params
  end

  def authorize(_req, user), do: Model.User.admin?(user)

  def exec(req) do
    case find(req.params[:node_id]) do
      nil ->
        {:error, "Object not found"}

      node ->
        update(node, req.input)
    end
  end

  def find(id), do: Model.Query.Node.get(id)

  def update(node, params) do
    case Model.Query.Node.update(node, params) do
      {:ok, node} ->
        node

      {:error, changeset} ->
        {:error, "Validation failed", errors: Enum.map(
          changeset.errors, fn {k, {msg, _opts}} -> {k, [msg]} end
        ) |> Map.new}
    end
  end
end
