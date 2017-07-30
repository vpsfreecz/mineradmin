defmodule MinerAdmin.Api.Program.Create do
  use HaveAPI.Action.Create
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  input do
    use Api.Program.Params, only: [:label, :description, :module]

    patch :label, validate: [required: true]
    patch :module, validate: [required: true]
  end

  output do
    use Api.Program.Params
  end

  def authorize(_req, user), do: Api.Authorize.admin(user)

  def exec(req) do
    case Base.Query.Program.create(req.input) do
      {:ok, prog} ->
        prog

      {:error, changeset} ->
        Api.format_errors(changeset)
    end
  end
end
