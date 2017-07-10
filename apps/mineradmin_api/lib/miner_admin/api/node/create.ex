defmodule MinerAdmin.Api.Node.Create do
  use HaveAPI.Action.Create
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
    case Model.Query.Node.create(req.input) do
      {:ok, node} ->
        node

      {:error, changeset} ->
        {:error, "Validation failed", errors: Enum.map(
          changeset.errors, fn {k, {msg, _opts}} -> {k, [msg]} end
        ) |> Map.new}
    end
  end
end
