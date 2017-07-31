defmodule MinerAdmin.Api.UserProgram.Gpu.Index do
  use HaveAPI.Action.Index
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  output do
    use Api.UserProgram.Gpu.Params
  end

  def authorize(_req, _user), do: :allow

  def items(req) do
    case find(req.params[:userprogram_id], req.user) do
      nil ->
        {:error, "UserProgram not found", http_status: 404}

      user_prog ->
        user_prog
        |> Base.Query.UserProgram.gpus()
        |> Enum.map(fn gpu -> %{id: gpu.id, gpu: [gpu.id]} end)
    end
  end

  def count(req) do
    Base.Query.UserProgram.gpus_count(req.params[:userprogram_id])
  end

  defp find(id, user) do
    Base.Query.UserProgram.get(id, user)
  end
end
