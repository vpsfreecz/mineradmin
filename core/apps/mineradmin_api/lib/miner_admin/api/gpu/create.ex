defmodule MinerAdmin.Api.Gpu.Create do
  use HaveAPI.Action.Create
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  input do
    params = ~w(user node vendor uuid)a
    use Api.Gpu.Params, only: params

    for p <- params do
      patch p, validate: [required: true]
    end
  end

  output do
    use Api.Gpu.Params
  end

  def authorize(_req, user), do: Base.User.admin?(user)

  def exec(req) do
    case Base.Query.Gpu.create(Api.associatify(req.input, [:user, :node])) do
      {:ok, gpu} ->
        Api.resourcify(gpu, [:user, :node])

      {:error, changeset} ->
        Api.format_errors(changeset)
    end
  end
end
