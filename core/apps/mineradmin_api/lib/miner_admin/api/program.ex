defmodule MinerAdmin.Api.Program do
  use HaveAPI.Resource
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  defmodule Params do
    use HaveAPI.Parameters

    integer :id
    string :label
    string :description
    string :module
    datetime :inserted_at
    datetime :updated_at
  end

  actions [
    Api.Program.Index,
    Api.Program.Show,
    Api.Program.Create,
    Api.Program.Update,
    Api.Program.Delete,
  ]
end
