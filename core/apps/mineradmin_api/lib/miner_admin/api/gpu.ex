defmodule MinerAdmin.Api.Gpu do
  use HaveAPI.Resource
  alias MinerAdmin.Api
  alias MinerAdmin.Base

  defmodule Params do
    use HaveAPI.Parameters

    integer :id
    resource [Api.User]
    resource [Api.Node]
    string :vendor, validate: [include: [
      values: Base.Schema.Gpu.Vendor.__enum_map__
              |> Keyword.keys()
              |> Enum.map(&to_string/1)
    ]]
    string :uuid
    string :name
    datetime :inserted_at
    datetime :updated_at
  end

  actions [
    Api.Gpu.Index,
    Api.Gpu.Show,
    Api.Gpu.Create,
    Api.Gpu.Delete,
  ]
end
