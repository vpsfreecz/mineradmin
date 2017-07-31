defmodule MinerAdmin.Api.UserProgram.Create do
  use HaveAPI.Action.Create
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  input do
    use Api.UserProgram.Params, only: ~w(user program node label cmdline)a

    for p <- ~w(user program node label)a do
      patch p, validate: [required: true]
    end
  end

  output do
    use Api.UserProgram.Params
  end

  def authorize(_req, user), do: Api.Authorize.admin(user)

  def exec(req) do
    case Base.UserProgram.create(Api.associatify(req.input, [:user, :program, :node])) do
      {:ok, user_prog} ->
        Api.resourcify(user_prog, [:user, :program, :node])

      {:error, changeset} ->
        Api.format_errors(changeset)
    end
  end
end
