defmodule MinerAdmin.Api.User.Update do
  use HaveAPI.Action.Update
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  input do
    use Api.User.Params, only: [:login, :role]
    string :password
  end

  output do
    use Api.User.Params
  end

  def authorize(_req, user), do: Api.Authorize.admin(user)

  def exec(req) do
    case find(req.params[:user_id]) do
      nil ->
        {:error, "Object not found"}

      user ->
        update(user, req.input)
    end
  end

  def find(id), do: Base.Query.User.get(id)

  def update(user, params) do
    case Base.Query.User.update(user, params) do
      {:ok, user} ->
        Api.resourcify(user, [:auth_backend])

      {:error, changeset} ->
        Api.format_errors(changeset)
    end
  end
end
