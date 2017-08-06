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

  def authorize(%HaveAPI.Request{}, session) do
    if Base.User.admin?(session) do
      :allow

    else
      {:allow, blacklist: [:user]}
    end
  end

  def authorize(_res, _user), do: :allow

  def create(req) do
    ret = req
      |> params(Base.User.admin?(req.user))
      |> Api.associatify([:user, :program, :node])
      |> Base.UserProgram.create()

    case ret do
      {:ok, user_prog} ->
        user_prog
        |> Api.UserProgram.resource()
        |> Api.resourcify([:user, :program, :node])

      {:error, changeset} ->
        Api.format_errors(changeset)
    end
  end

  defp params(req, true), do: req.input
  defp params(req, false), do: Map.put(req.input, :user, req.user.user_id)
end
