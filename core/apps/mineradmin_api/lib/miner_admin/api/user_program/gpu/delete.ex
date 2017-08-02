defmodule MinerAdmin.Api.UserProgram.Gpu.Delete do
  use HaveAPI.Action.Delete
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  def authorize(_req, _session), do: :allow

  def exec(req) do
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
        delete(user_prog, gpu)
        :ok
    end
  end

  def delete(user_prog, gpu) do
    Base.Query.UserProgram.remove_gpu(user_prog, gpu)
  end
end
