defmodule MinerAdmin.Api.Gpu.Delete do
  use HaveAPI.Action.Delete
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  def authorize(_req, user), do: Base.User.admin?(user)

  def exec(req) do
    case find(req.params[:gpu_id], req.user) do
      nil ->
        {:error, "Object not found"}

      gpu ->
        delete(gpu)
    end
  end

  def find(id, user), do: Base.Query.Gpu.get(id, user)

  def delete(gpu) do
    case Base.Query.Gpu.delete(gpu) do
      {:ok, _} ->
        :ok

      {:error, changeset} ->
        Api.format_errors(changeset)
    end
  end
end
