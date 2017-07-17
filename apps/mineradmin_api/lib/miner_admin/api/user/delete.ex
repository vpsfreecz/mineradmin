defmodule MinerAdmin.Api.User.Delete do
  use HaveAPI.Action.Delete
  alias MinerAdmin.Api
  alias MinerAdmin.Model

  def authorize(_req, user), do: Model.User.admin?(user)

  def exec(req) do
    case find(req.params[:user_id]) do
      nil ->
        {:error, "Object not found"}

      user ->
        delete(user)
    end
  end

  def find(id), do: Model.Query.User.get(id)

  def delete(user) do
    case Model.Query.User.delete(user) do
      {:ok, _} ->
        :ok

      {:error, changeset} ->
        {:error, "Validation failed", errors: Enum.map(
          changeset.errors, fn {k, {msg, _opts}} -> {k, [msg]} end
        ) |> Map.new}
    end
  end
end
