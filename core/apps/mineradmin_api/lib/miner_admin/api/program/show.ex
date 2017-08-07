defmodule MinerAdmin.Api.Program.Show do
  use HaveAPI.Action.Show
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  output do
    use Api.Program.Params
  end

  def authorize(_req, _session), do: :allow
  def find(req), do: Base.Query.Program.get(req.params[:program_id])
end
