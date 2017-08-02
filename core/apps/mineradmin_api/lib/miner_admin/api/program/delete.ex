defmodule MinerAdmin.Api.Program.Delete do
  use HaveAPI.Action.Delete
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  def authorize(_req, session), do: Api.Authorize.admin(session)

  def exec(req) do
    case find(req.params[:program_id]) do
      nil ->
        {:error, "Object not found"}

      prog ->
        delete(prog)
    end
  end

  def find(id), do: Base.Query.Program.get(id)

  def delete(prog) do
    case Base.Query.Program.delete(prog) do
      {:ok, _} ->
        :ok

      {:error, changeset} ->
        Api.format_errors(changeset)
    end
  end
end
