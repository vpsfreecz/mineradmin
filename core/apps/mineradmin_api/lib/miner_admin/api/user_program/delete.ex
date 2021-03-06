defmodule MinerAdmin.Api.UserProgram.Delete do
  use HaveAPI.Action.Delete
  alias MinerAdmin.Api
  alias MinerAdmin.Base

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
    case Base.UserProgram.delete(user_prog) do
      {:ok, _} ->
        :ok

      {:error, msg} when is_binary(msg) ->
        {:error, msg}

      {:error, msg, opts} ->
        {:error, msg, opts}

      {:error, changeset} ->
        Api.format_errors(changeset)
    end
  end
end
