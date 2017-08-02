defmodule MinerAdmin.Api.Program.Update do
  use HaveAPI.Action.Update
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  input do
    use Api.Program.Params, only: [:label, :description]
  end

  output do
    use Api.Program.Params
  end

  def authorize(_req, session), do: Api.Authorize.admin(session)

  def exec(req) do
    case find(req.params[:program_id]) do
      nil ->
        {:error, "Object not found"}

      prog ->
        update(prog, req.input)
    end
  end

  def find(id), do: Base.Query.Program.get(id)

  def update(prog, params) do
    case Base.Query.Program.update(prog, params) do
      {:ok, prog} ->
        prog

      {:error, changeset} ->
        Api.format_errors(changeset)
    end
  end
end
