defmodule MinerAdmin.Api.Node do
  use HaveAPI.Resource

  defmodule Params do
    use HaveAPI.Parameters

    integer :id
    string :name
    string :domain
  end

  actions [
    MinerAdmin.Api.Node.Index,
    MinerAdmin.Api.Node.Show,
    MinerAdmin.Api.Node.Create,
    MinerAdmin.Api.Node.Update,
    MinerAdmin.Api.Node.Delete,
  ]
end
