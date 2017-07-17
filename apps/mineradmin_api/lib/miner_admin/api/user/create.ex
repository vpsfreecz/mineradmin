defmodule MinerAdmin.Api.User.Create do
  use HaveAPI.Action.Create
  alias MinerAdmin.Api
  alias MinerAdmin.Model

  input do
    use Api.User.Params, only: [:login, :role, :auth_backend]
    string :password

    patch :login, validate: [required: true]
    patch :role, validate: [required: true]
  end

  output do
    use Api.User.Params
  end

  def authorize(_req, user), do: Model.User.admin?(user)

  def exec(req) do
    case Model.Query.User.create(Api.associatify(req.input, [:auth_backend])) do
      {:ok, user} ->
        Api.resourcify(user, [:auth_backend])

      {:error, changeset} ->
        {:error, "Validation failed", errors: Enum.map(
          changeset.errors, fn {k, {msg, _opts}} -> {k, [msg]} end
        ) |> Map.new}
    end
  end
end
