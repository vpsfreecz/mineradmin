defmodule MinerAdmin.Api.AuthBackend do
  use HaveAPI.Resource
  alias MinerAdmin.Api

  defmodule Params do
    use HaveAPI.Parameters

    integer :id
    string :label
    string :module
    custom :opts
  end

  actions [
    Api.AuthBackend.Index,
    Api.AuthBackend.Show,
  ]
end
