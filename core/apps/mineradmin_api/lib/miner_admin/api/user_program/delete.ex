defmodule MinerAdmin.Api.UserProgram.Delete do
  use HaveAPI.Action.Delete
  alias MinerAdmin.Api
  alias MinerAdmin.Base
  alias MinerAdmin.Control

  def authorize(_req, _session), do: :allow

  def exec(req) do
    case find(req.params[:userprogram_id], req.user.user) do
      nil ->
        {:error, "Object not found"}

      gpu ->
        delete(gpu)
    end
  end

  def find(id, user), do: Base.Query.UserProgram.get(id, user)

  def delete(user_prog) do
    case Control.UserProgram.delete(user_prog) do
      {:ok, _} ->
        :ok

      {:error, changeset} ->
        Api.format_errors(changeset)
    end
  end
end
