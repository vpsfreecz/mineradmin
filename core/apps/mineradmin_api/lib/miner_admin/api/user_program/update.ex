defmodule MinerAdmin.Api.UserProgram.Update do
  @moduledoc """
  Update `label` or program's `cmdline`. Note that `cmdline` changes will take
  effect during the next start, not immediately.
  """

  use HaveAPI.Action.Update
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  input do
    use Api.UserProgram.Params, only: [:label, :cmdline]
  end

  output do
    use Api.UserProgram.Params
  end

  def authorize(_req, user), do: Api.Authorize.admin(user)

  def exec(req) do
    case find(req.params[:userprogram_id], req.user) do
      nil ->
        {:error, "Object not found"}

      user_prog ->
        update(user_prog, req.input)
    end
  end

  def find(id, user), do: Base.Query.UserProgram.get(id, user)

  def update(user_prog, params) do
    case Base.Query.UserProgram.update(user_prog, params) do
      {:ok, user_prog} ->
        Api.resourcify(user_prog, [:user, :program, :node])

      {:error, changeset} ->
        Api.format_errors(changeset)
    end
  end
end
