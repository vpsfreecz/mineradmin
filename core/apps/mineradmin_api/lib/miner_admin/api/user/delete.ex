defmodule MinerAdmin.Api.User.Delete do
  use HaveAPI.Action.Delete
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  def authorize(_req, session), do: Api.Authorize.admin(session)

  def exec(req) do
    case find(req.params[:user_id]) do
      nil ->
        {:error, "Object not found"}

      user ->
        delete(user)
    end
  end

  def find(id), do: Base.Query.User.get(id)

  def delete(user) do
    case Base.Query.User.delete(user) do
      {:ok, _} ->
        :ok

      {:error, changeset} ->
        Api.format_errors(changeset)
    end
  end
end
