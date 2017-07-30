defmodule MinerAdmin.Api.UserProgram.Gpu.Create do
  use HaveAPI.Action.Create
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  input do
    use Api.UserProgram.Gpu.Params, only: [:gpu]

    patch :gpu, validate: [required: true]
  end

  output do
    use Api.UserProgram.Gpu.Params
  end

  def authorize(_req, user), do: Api.Authorize.admin(user)

  def exec(req) do
    case find_prog(req.params[:userprogram_id], req.user) do
      nil ->
        {:error, "UserProgram not found", http_status: 404}

      user_prog ->
        case find_gpu(req.input.gpu, req.user) do
          nil ->
            {:error, "Gpu not found", http_status: 404}

          gpu ->
            add_gpu(user_prog, gpu)
        end
    end
  end

  defp find_prog(id, user) do
    Base.Query.UserProgram.get(id, user)
  end

  defp find_gpu(id, user) do
    Base.Query.Gpu.get(id, user)
  end

  defp add_gpu(user_prog, gpu) do
    case Base.Query.UserProgram.add_gpu(user_prog, gpu) do
      {:ok, user_prog} ->
        IO.inspect user_prog
        %{id: gpu.id, gpu: [gpu.id]}

      {:error, changeset} ->
        Api.format_errors(changeset)
    end
  end
end
