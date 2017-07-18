defmodule MinerAdmin.Api.User do
  use HaveAPI.Resource
  alias MinerAdmin.Api

  defmodule Params do
    use HaveAPI.Parameters

    integer :id
    string :login
    integer :role
    resource [Api.AuthBackend], name: :auth_backend
    datetime :inserted_at
    datetime :updated_at
  end

  actions [
    Api.User.Index,
    Api.User.Show,
    Api.User.Create,
    Api.User.Update,
    Api.User.Delete,
  ]
end
