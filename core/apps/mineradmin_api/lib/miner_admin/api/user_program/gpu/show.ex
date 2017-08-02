defmodule MinerAdmin.Api.UserProgram.Gpu.Show do
  use HaveAPI.Action.Show
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  output do
    use Api.UserProgram.Gpu.Params
  end

  def authorize(_req, _session), do: :allow

  def item(req) do
    case find_prog(req.params[:userprogram_id], req.user.user) do
      nil ->
        {:error, "UserProgram not found", http_status: 404}

      user_prog ->
        find_gpu(user_prog, req.params[:gpu_id])
    end
  end

  defp find_prog(id, user) do
    Base.Query.UserProgram.get(id, user)
  end

  defp find_gpu(user_prog, id) do
    case Base.Query.UserProgram.get_gpu(user_prog, id) do
      nil ->
        {:error, "Gpu not found", http_status: 404}

      gpu ->
        %{id: gpu.id, gpu: [gpu.id]}
    end
  end
end
