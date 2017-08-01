defmodule MinerAdmin.Api.UserProgram do
  use HaveAPI.Resource
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  defmodule Params do
    use HaveAPI.Parameters

    integer :id
    resource [Api.User], value_label: :login
    resource [Api.Program]
    resource [Api.Node], value_label: :name
    string :label
    string :cmdline
    boolean :active
    datetime :inserted_at
    datetime :updated_at
  end

  actions [
    Api.UserProgram.Index,
    Api.UserProgram.Show,
    Api.UserProgram.Create,
    Api.UserProgram.Update,
    Api.UserProgram.Delete,
    Api.UserProgram.Start,
    Api.UserProgram.Stop,
    Api.UserProgram.Restart,
  ]

  resources [
    Api.UserProgram.Gpu,
  ]
end
