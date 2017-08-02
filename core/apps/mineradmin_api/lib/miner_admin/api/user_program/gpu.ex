defmodule MinerAdmin.Api.UserProgram.Gpu do
  use HaveAPI.Resource
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  defmodule Params do
    use HaveAPI.Parameters

    integer :id
    resource [Api.Gpu], value_label: :name
  end

  resource_route ':userprogram_id/gpu'

  actions [
    Api.UserProgram.Gpu.Index,
    Api.UserProgram.Gpu.Show,
    Api.UserProgram.Gpu.Create,
    Api.UserProgram.Gpu.Delete,
  ]
end
