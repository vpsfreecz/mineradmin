defmodule MinerAdmin.Api.UserProgram.Delete do
  use HaveAPI.Action.Delete
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  def authorize(_req, user), do: Base.User.admin?(user)

  def exec(req) do
    case find(req.params[:userprogram_id], req.user) do
      nil ->
        {:error, "Object not found"}

      gpu ->
        delete(gpu)
    end
  end

  def find(id, user), do: Base.Query.UserProgram.get(id, user)

  def delete(user_prog) do
    case Base.UserProgram.delete(user_prog) do
      {:ok, _} ->
        :ok

      {:error, changeset} ->
        Api.format_errors(changeset)
    end
  end
end
